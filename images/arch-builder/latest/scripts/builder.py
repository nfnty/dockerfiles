#!/usr/bin/python3 -u
''' Arch package build script '''

import subprocess
import os
import sys
import argparse
import shutil
import re
from typing import List, Optional, Set, Tuple

import requests

PATH_TMPDIR = os.environ['TMPDIR'] if 'TMPDIR' in os.environ else '/tmp'
PATH_PKGBUILD = os.path.join(PATH_TMPDIR, 'pkgbuild')
PATH_BUILDDIR = os.path.join(PATH_TMPDIR, 'build')
PATH_LIB = '/var/lib/builder'
PATH_PKGDEST = os.path.join(PATH_LIB, 'pkg')
PATH_GPG = os.environ['GNUPGHOME'] if 'GNUPGHOME' in os.environ else \
    os.path.join(PATH_LIB, 'gnupg')


def failed(string: str) -> None:
    ''' Print and exit '''
    print(string, file=sys.stderr)
    sys.exit(1)


def print_separator() -> None:
    ''' Prints a separator for redability '''
    print('\n##################################################\n')


def args_parse() -> argparse.Namespace:
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(description='Arch package build script')

    # Main arguments
    method = parser.add_mutually_exclusive_group(required=True)
    method.add_argument('--aur', metavar='NAME', help='Build from AUR')
    method.add_argument('--git', metavar='URL', help='Build from remote git repository')
    method.add_argument('--local', metavar='PATH', help='Build from local path')
    method.add_argument('--remote', metavar='URL', help='Build from remote PKGBUILD or archive')
    method.add_argument('--gpginit', action='store_true',
                        help='Initialize GPG in {0:s}'.format(PATH_GPG))
    method.add_argument('--dbreset', action='store_true', help='Reset database')
    method.add_argument('--pkgcleanup', action='store_true',
                        help='Remove packages not in database')

    # Options
    parser.add_argument('--db', metavar='NAME', help='Create database in pkgdest root')
    parser.add_argument('--path', metavar='PATH', help='Relative path to PATH_PKGBUILD directory')
    parser.add_argument('--pathfind', metavar='NAME', help='Package name to find')
    parser.add_argument('--noclean', action='store_true', help='No builddir cleaning')
    parser.add_argument('--nosign', action='store_true', help='No package/database signing')
    parser.add_argument('--noforce', action='store_true', help='No overwriting current package')
    parser.add_argument('--removeold', action='store_true', help='Remove old package after build')
    parser.add_argument('--repackage', action='store_true', help='Only run package()')
    parser.add_argument('--noprepare', action='store_true', help='Do not run prepare()')

    args = parser.parse_args()

    # Workaround for container config immutability
    for attribute in args.__dict__:
        if isinstance(args.__dict__[attribute], bool) and \
                os.path.exists(os.path.join(PATH_BUILDDIR, '.' + attribute)):
            args.__dict__[attribute] = True

    if args.aur and args.path:
        print('--aur and PATH are mutually exclusive\n')
        parser.print_help()
        sys.exit(2)
    if (args.pkgcleanup or args.dbreset) and not args.db:
        print('--db also needs to be specified\n')
        parser.print_help()
        sys.exit(2)
    if args.path and args.pathfind:
        print('--path and --pathfind are mutually exclusive\n')
        parser.print_help()
        sys.exit(2)

    return args


def gpg_init() -> None:
    ''' Initialize GnuPG '''
    batchcfg_path = os.path.join(PATH_GPG, 'batch.conf')

    try:
        subprocess.run([
            '/usr/bin/gpg', '--verbose', '--no-tty',
            '--full-gen-key', '--batch', batchcfg_path
        ], check=True)
    except subprocess.CalledProcessError as error:
        failed('Failed to generate GnuPG key in: {0:s}\n{1:s}'.format(PATH_GPG, str(error)))

    try:
        subprocess.run(['/usr/bin/gpg', '--armor', '--export'], check=True)
    except subprocess.CalledProcessError as error:
        failed('Failed to export GnuPG key from: {0:s}\n{1:s}'.format(PATH_GPG, str(error)))


def gpg_hack() -> None:
    ''' Reset GPG '''
    try:
        subprocess.run([
            '/usr/bin/gpg', '--list-secret-keys'
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError as error:
        failed('GPG hack failed\n{0:s}'.format(str(error)))


def pacman_upgrade() -> None:
    ''' Pacman upgrade '''
    try:
        subprocess.run([
            '/usr/bin/sudo', '--non-interactive',
            '/usr/bin/pacman', '--sync', '--noconfirm',
            '--refresh', '--sysupgrade'
        ], check=True)
    except subprocess.CalledProcessError as error:
        failed('Pacman upgrade failed\n{0:s}'.format(str(error)))


def db_files(path: str) -> Optional[Set[str]]:
    ''' Parse database and return files '''
    try:
        output = subprocess.run([
            '/usr/bin/tar', '--extract', '--xz',
            '--to-stdout', '--wildcards',
            '--file={0:s}'.format(path),
            '*/desc'
        ], check=True, stdout=subprocess.PIPE).stdout.decode('UTF-8')
    except subprocess.CalledProcessError as error:
        print('Failed tar extraction: {0:s}'.format(str(error)), file=sys.stderr)
        return None

    return set(re.findall(r'^%FILENAME%$\n(.*)\n', output, re.MULTILINE))


def packages_cleanup(path_packages: str, db_name: str) -> None:
    ''' Cleanup packages not present in database '''
    print('Starting cleanup:\nDatabase: {0:s}\nPath: {1:s}'.format(db_name, path_packages))

    path_db = os.path.join(path_packages, db_name + '.db.tar.xz')
    if not os.path.exists(path_db):
        failed('Couldn\'t find database file')

    files_db = db_files(path_db)
    if files_db is None:
        failed('Failed parsing database')
        assert False, 'Unreachable code'
    if not files_db:
        failed('Failed: Found no packages')
    if '' in files_db:
        failed('Failed parsing database: Empty filename present')
    files_db |= {filename + '.sig' for filename in files_db}

    files_packages = {filename for filename in os.listdir(path_packages)
                      if filename.endswith(('.pkg.tar.xz', '.pkg.tar.xz.sig'))}

    for filename in sorted(files_packages - files_db):
        os.remove(os.path.join(path_packages, filename))
        print('Removed: {0:s}'.format(filename))

    print('\nPackage cleanup finished!')


def packages_mtime(path_packages: str) -> List[Tuple[str, float]]:
    ''' Packages sorted by mtime '''
    packages: List[Tuple[str, float]] = [
        (
            os.path.join(path_packages, filename),
            os.stat(os.path.join(path_packages, filename)).st_mtime,
        )
        for filename in os.listdir(path_packages)
        if filename.endswith('.pkg.tar.xz')
    ]
    return sorted(packages, key=lambda package: package[1])


def packages_newer(path_packages: str, path: str) -> List[str]:
    ''' Packages newer than path '''
    mtime_path = os.stat(path).st_mtime
    packages = packages_mtime(path_packages)
    return [path for path, mtime in packages if mtime >= mtime_path]


def db_update() -> None:
    ''' Update database '''
    path_db = os.path.join(PATH_PKGDEST, ARGS.db + '.db.tar.xz')

    cmd = ['/usr/bin/repo-add', path_db]
    if not ARGS.nosign:
        cmd.insert(1, '--sign')
    if ARGS.removeold:
        cmd.insert(1, '--remove')

    if ARGS.dbreset:
        print('Removing database files')
        for filename in os.listdir(PATH_PKGDEST):
            if re.fullmatch(r'^[^.]+\.(db|files)\.tar\.xz.*$', filename):
                os.remove(os.path.join(PATH_PKGDEST, filename))
                print(filename)
        print()

        packages = [path for path, _ in packages_mtime(PATH_PKGDEST)]
    else:
        packages = packages_newer(PATH_PKGDEST, path_db)
    if not packages:
        failed('Found no packages')

    try:
        subprocess.run(cmd + packages, check=True)
    except subprocess.CalledProcessError as error:
        failed('Failed to create db!\n{0:s}'.format(str(error)))


def extract_tar(data: bytes, extension: str, path_dest: str) -> None:
    ''' Extract tar '''
    cmd = ['/usr/bin/tar', '--extract', '--file=-', '--strip-components=1',
           '--directory={0:s}'.format(path_dest)]

    # Check extension
    if extension == '.tar.gz':
        cmd.insert(2, '--gzip')
    elif extension == '.tar.xz':
        cmd.insert(2, '--xz')
    elif extension == '.tar':
        pass
    else:
        failed('Failed archive extraction: Unknown extension: {0:s}'.format(extension))

    try:
        subprocess.run(cmd, input=data, check=True)
    except subprocess.CalledProcessError as error:
        failed('Failed archive extraction: {0:s}\n{1:s}'.format(extension, str(error)))
    print('Archive extracted: {0:s}'.format(extension))


def prepare_git(url: str, path: str) -> None:
    ''' Prepare git pkgbuild directory '''
    try:
        subprocess.run(['/usr/bin/git', 'clone', url, path], check=True)
    except subprocess.CalledProcessError as error:
        failed('Failed to clone repository\n{0:s}'.format(str(error)))
    print('Successfully cloned repository: {0:s}'.format(url))


def prepare_remote(url: str, path: str) -> None:
    ''' Prepare remote pkgbuild directory '''
    try:
        response = requests.get(url)
    except requests.ConnectionError as error:
        failed('Failed to download sources\n{0:s}'.format(str(error)))

    if response.ok:
        print('Successfully downloaded: {0:s}'.format(url))

        url_base = url.rsplit('?')[0]
        if url_base.endswith('.tar.gz'):
            extract_tar(response.content, '.tar.gz', path)
        elif url_base.endswith('.tar.xz'):
            extract_tar(response.content, '.tar.xz', path)
        elif url_base.endswith('.tar'):
            extract_tar(response.content, '.tar', path)
        elif url_base.endswith('PATH_PKGBUILD'):
            with open(os.path.join(path, 'PATH_PKGBUILD'), 'wb') as file:
                file.write(response.content)
        else:
            failed('Incorrect remote type')
    else:
        failed('Failed to download remote: {0:s}'.format(url))


def path_find(base_path: str, name: str) -> Optional[str]:
    ''' Find PATH_PKGBUILD path for name '''
    for root, dirnames, _ in os.walk(base_path):
        if name in dirnames and os.path.exists(os.path.join(root, name, 'PKGBUILD')):
            return os.path.join(root, name)
    return None


def package_make() -> None:
    ''' Make package '''
    cmd = ['/usr/bin/makepkg', '--noconfirm', '--log', '--syncdeps']

    if not ARGS.noforce:
        cmd.append('--force')

    if ARGS.nosign:
        cmd.append('--nosign')
    else:
        cmd.append('--sign')

    if ARGS.repackage:
        cmd.append('--repackage')
    elif ARGS.noprepare:
        cmd.append('--noprepare')

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as error:
        failed('Failed to make package!\n{0:s}'.format(str(error)))


def main() -> None:  # pylint: disable=too-many-branches,too-many-statements
    ''' Main '''
    print_separator()

    # Options
    if ARGS.gpginit:
        gpg_init()
        sys.exit(0)
    elif ARGS.dbreset:
        print('Resetting database!\n')
        db_update()
        sys.exit(0)
    elif ARGS.pkgcleanup:
        packages_cleanup(PATH_PKGDEST, ARGS.db)
        sys.exit(0)

    # Upgrade databases and packages
    pacman_upgrade()
    print_separator()

    # Prepare PATH_PKGBUILD root
    try:
        shutil.rmtree(PATH_PKGBUILD)
    except FileNotFoundError:
        pass
    os.mkdir(PATH_PKGBUILD)
    os.chdir(PATH_PKGBUILD)

    if ARGS.local:
        os.chdir(ARGS.local)
    elif ARGS.git:
        prepare_git(ARGS.git, PATH_PKGBUILD)
    elif ARGS.aur:
        prepare_git('https://aur.archlinux.org/{0:s}.git'.format(ARGS.aur), PATH_PKGBUILD)
    elif ARGS.remote:
        prepare_remote(ARGS.remote, PATH_PKGBUILD)

    # cd to specified relpath
    if ARGS.pathfind:
        path = path_find(os.getcwd(), ARGS.pathfind)
        if not path:
            failed('Failed to find path: {0:s}'.format(ARGS.pathfind))
            assert False, 'Unreachable code'
        os.chdir(path)
    elif ARGS.path:
        os.chdir(ARGS.path)
        print('Successfully changed directory to: {0:s}'.format(ARGS.path))
    print_separator()

    # Clean builddir
    if not ARGS.noclean and not ARGS.repackage and not ARGS.noprepare:
        try:
            subprocess.run(['/usr/bin/chmod', '--recursive', 'u+rwX', PATH_BUILDDIR], check=True)
        except subprocess.CalledProcessError as error:
            failed(str(error))
        shutil.rmtree(PATH_BUILDDIR)
        os.mkdir(PATH_BUILDDIR)

    # Build package
    package_make()

    # Create Database
    if ARGS.db:
        # gpg hack: sign error EOF otherwise
        gpg_hack()

        print_separator()
        db_update()


if __name__ == '__main__':
    ARGS = args_parse()
    main()
