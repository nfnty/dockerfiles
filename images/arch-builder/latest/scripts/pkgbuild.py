#!/usr/bin/python3 -u
''' Arch Docker package build script '''

import subprocess
import os
import sys
import argparse
import requests
import pygit2
import time
import signal

PRIMPATH = os.environ['PRIMPATH']
PKGBUILD = os.path.join(PRIMPATH, 'pkgbuild')
BUILDDIR = os.path.join(PRIMPATH, 'builddir')
MAKEPKGCFG = os.path.join(PRIMPATH, 'config/makepkg.conf')
PKGDEST = os.path.join(PRIMPATH, 'pkgdest')
HOSTPKGBUILD = os.path.join(PRIMPATH, 'host/pkgbuild')
GPGPATH = os.environ['GNUPGHOME']

def signal_handle_sigchld(signum, frame):
    ''' Handle zombie processes '''
    os.waitpid(0, os.WNOHANG)
def error_print_exit(error):
    ''' Print error and exit '''
    print(str(error))
    sys.exit(1)

def args_parse():
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(
        description='Arch Docker package build script'
    )

    # Main arguments
    method = parser.add_mutually_exclusive_group(required=True)

    method.add_argument(
        '--aur', metavar='NAME',
        help='Build from AUR'
    )
    method.add_argument(
        '--git', metavar='URL',
        help='Build from remote git repository'
    )
    method.add_argument(
        '--local', action='store_true',
        help='Build from local path ' + HOSTPKGBUILD
    )
    method.add_argument(
        '--remote', metavar='URL',
        help='Build from remote PKGBUILD or archive (tar / tar.gz / tar.xz)'
    )

    method.add_argument(
        '--gpginit', action='store_true',
        help='Initialize GnuPG in ' + GPGPATH
    )
    method.add_argument(
        '--dbreset', action='store_true',
        help='Remove database and add the latest packages in ' + PKGDEST
    )
    method.add_argument(
        '--pkgcleanup', action='store_true',
        help='Remove all packages not present in database in ' + PKGDEST
    )

    # Options
    parser.add_argument(
        '--pkg', metavar='PKG', nargs='+',
        help='Name of specific package(s) of group'
    )
    parser.add_argument(
        '--db', metavar='NAME',
        help='Create database in pkgdest root'
    )
    parser.add_argument(
        '--path', metavar='PATH',
        help='Relative path to PKGBUILD directory',
    )
    parser.add_argument(
        '--noclean', action='store_true',
        help='Do not clean builddir'
    )
    parser.add_argument(
        '--nosign', action='store_true',
        help='Do not sign package(s) and database',
    )
    parser.add_argument(
        '--noforce', action='store_true',
        help='Do not force overwrite old package',
    )
    parser.add_argument(
        '--removeold', action='store_true',
        help='Remove old package after build',
    )

    args = parser.parse_args()

    # AUR and PATH are mutually exclusive
    if args.aur and args.path:
        print('--aur and PATH are mutually exclusive\n')
        parser.print_help()
        sys.exit(2)

    if (args.pkgcleanup or args.dbreset) and not args.db:
        print('--db also needs to be specified\n')
        parser.print_help()
        sys.exit(2)

    return args

def paxd_initialize():
    ''' Initalize paxd '''
    process = subprocess.Popen(
        [
            '/usr/bin/sudo', '--non-interactive',
            '/usr/bin/paxd'
        ],
        stderr=subprocess.PIPE
    )

    for timer_wait in range(51):
        if process.stderr.readline().decode('UTF-8').strip() == \
                'loading configuration and applying all exceptions':
            break
        if timer_wait == 50:
            print('paxd took too long time to start')
            sys.exit(1)
        time.sleep(0.1)

    print('paxd started!')

def print_separator():
    ''' Prints a separator for redability '''
    print('\n##################################################\n')

def gpg_init():
    ''' Initialize GnuPG '''
    batchcfg_path = os.path.join(GPGPATH, 'batch.conf')

    try:
        subprocess.check_call(
            [
                '/usr/bin/gpg', '--verbose', '--no-tty',
                '--full-gen-key', '--batch', batchcfg_path
            ]
        )
    except subprocess.CalledProcessError as error:
        print('Failed to generate GnuPG key at ' + GPGPATH)
        error_print_exit(error)

    try:
        subprocess.check_call(['/usr/bin/gpg', '--armor', '--export'])
    except subprocess.CalledProcessError as error:
        print('Failed to export GnuPG key from ' + GPGPATH)
        error_print_exit(error)
def gpg_hack():
    ''' Reset gpg '''
    try:
        subprocess.check_call(
            ['/usr/bin/gpg', '--list-secret-keys'],
            stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
        )
    except subprocess.CalledProcessError as error:
        print('gpg hack failed!')
        error_print_exit(error)

def pacman_upgrade():
    ''' Pacman upgrade '''
    try:
        subprocess.check_call(
            [
                '/usr/bin/sudo', '--non-interactive',
                '/usr/bin/pacman', '--sync', '--noconfirm',
                '--refresh', '--sysupgrade'
            ]
        )
    except subprocess.CalledProcessError as error:
        print('Pacman failed!')
        error_print_exit(error)
def path_clean(path):
    ''' Clean builddir '''
    try:
        subprocess.check_call(
            [
                '/usr/bin/sudo', '--non-interactive',
                '/usr/bin/find', path,
                '-mindepth', '1', '-delete'
            ]
        )
    except subprocess.CalledProcessError as error:
        print('Failed to clean ' + path)
        error_print_exit(error)

    print(path + ' cleanup finished!')

def packages_cleanup(path_base, db_name):
    ''' Cleanup packages not present in database '''
    print('Starting cleanup in ' + path_base)
    print('Database ' + db_name + '\n')

    path_db = os.path.join(path_base, db_name + '.db.tar.xz')

    try:
        os.stat(path_db)
    except FileNotFoundError as error:
        print('Couldn\'t find database file: ' + path_db)
        error_print_exit(error)

    try:
        output = subprocess.check_output(
            [
                '/usr/bin/tar', '--extract', '--xz',
                '--to-stdout', '--wildcards',
                '--file', path_db,
                '*/desc'
            ]
        ).decode('UTF-8').replace('\n\n', '\n').splitlines()
    except subprocess.CalledProcessError as error:
        print('tar failed!')
        error_print_exit(error)

    files_db = []
    nextline = False
    for line in output:
        if nextline:
            files_db.append(line)
            nextline = False
        if line == '%FILENAME%':
            nextline = True

    try:
        files_packages = subprocess.check_output(
            [
                '/usr/bin/find', path_base,
                '(',
                '-name', '*.pkg.tar.xz', '-or',
                '-name', '*.pkg.tar.xz.sig',
                ')',
                '-printf', '%f\\0'
            ]
        ).decode('UTF-8').split('\0')[:-1]
    except subprocess.CalledProcessError as error:
        print('find packages in ' + path_base + ' failed!')
        error_print_exit(error)

    for filename in files_db:
        if filename in files_packages:
            files_packages.remove(filename)
            try:
                files_packages.remove(filename + '.sig')
            except ValueError:
                pass

    for filename in files_packages:
        os.remove(os.path.join(path_base, filename))
        print('Removed: ' + filename)

    print('\nPackage cleanup finished!')

def packages_mtime(path_base):
    ''' Find and sort packages by modification time '''
    print('Finding and sorting packages by modification time in ' + path_base)

    try:
        packages = subprocess.check_output(
            [
                '/usr/bin/find', path_base,
                '-name', '*.pkg.tar.xz',
                '-printf', '%f\\0%T@\\0'
            ]
        ).decode('UTF-8').split('\0')[:-1]
    except subprocess.CalledProcessError as error:
        print('find failed!')
        error_print_exit(error)

    if not packages:
        print('Failed to find any packages')
        sys.exit(1)
    elif '' in packages:
        print('Find error: empty string found')
        sys.exit(1)

    packages = [
        (mtime, float(package))
        for (mtime, package) in zip(packages[0::2], packages[1::2])
    ]
    packages = sorted(packages, key=lambda package: package[1])
    packages = [os.path.join(path_base, package[0]) for package in packages]

    return packages
def packages_newer(path):
    ''' Find packages newer than path '''
    print('Finding packages newer than ' + path)
    cmd = ['/usr/bin/find', PKGDEST, '-name', '*.pkg.tar.xz', '-print0']

    try:
        os.stat(path)
        cmd.insert(-1, '-newer')
        cmd.insert(-1, path)
    except FileNotFoundError:
        pass

    try:
        packages = subprocess.check_output(cmd).decode('UTF-8').split('\0')[:-1]
    except subprocess.CalledProcessError as error:
        print('find packages newer than ' + path + ' failed!')
        error_print_exit(error)

    if not packages:
        print('Failed to find newer packages than ' + path)
        sys.exit(1)
    elif '' in packages:
        print('Find error: empty string found for ' + path)
        sys.exit(1)

    return packages

def db_update(args):
    ''' Update database '''
    print('Updating database!')

    db_path = os.path.join(PKGDEST, args.db + '.db.tar.xz')

    cmd = ['/usr/bin/repo-add', db_path]

    if not args.nosign:
        cmd.insert(1, '--sign')
    if args.removeold:
        cmd.insert(1, '--remove')

    if args.dbreset:
        try:
            os.remove(db_path)
        except FileNotFoundError:
            pass
        packages = packages_mtime(PKGDEST)
    else:
        packages = packages_newer(db_path)

    try:
        subprocess.check_call(cmd + packages)
    except subprocess.CalledProcessError as error:
        print('Failed to create db!')
        error_print_exit(error)

def extract_tar(content, extension):
    ''' Extract tar '''
    cmd = ['/usr/bin/tar', '--extract', '--strip-components=1', '--file=-']

    # Check extension
    if extension == '.tar.gz':
        cmd.insert(2, '--gzip')
    elif extension == '.tar.xz':
        cmd.insert(2, '--xz')
    elif extension == '.tar':
        pass
    else:
        print('ERROR: Wrong extension')
        sys.exit(1)

    p_tar = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    p_tar.stdin.write(content)
    p_tar.stdin.close()
    p_tar.wait(30)
    if p_tar.poll() == 0:
        print(extension + ' archive extracted!')
    else:
        print(extension + ' archive extraction failed!')
        sys.exit(1)

def prepare_local(path):
    ''' Prepare local pkgbuild directory '''
    if path:
        os.chdir(os.path.join(HOSTPKGBUILD, path))
    else:
        os.chdir(HOSTPKGBUILD)
    print('Successfully changed directory')
def prepare_git(url, path):
    ''' Prepare git pkgbuild directory '''
    try:
        pygit2.clone_repository(url=url, path=path)
    except pygit2.GitError as error:
        print('Failed to clone repository')
        error_print_exit(error)

    print('Successfully cloned repository: ' + url)
def prepare_aur(package):
    ''' Prepare AUR pkgbuild directory '''
    try:
        response = requests.get(
            'https://aur.archlinux.org/packages/' +
            package[:2] + '/' + package + '/' + package + '.tar.gz'
        )
    except requests.ConnectionError as error:
        print('Failed to download archive')
        error_print_exit(error)

    if response.ok:
        print('Successfully downloaded: ' + package)
        extract_tar(response.content, '.tar.gz')
    else:
        print('Failed to download archive')
        sys.exit(1)
def prepare_remote(url, path):
    ''' Prepare remote pkgbuild directory '''
    try:
        response = requests.get(url)
    except requests.ConnectionError as error:
        print('Failed to download sources')
        error_print_exit(error)

    if response.ok:
        print('Successfully downloaded: ' + url)

        url_base = url.rsplit('?')[0]

        if url_base.endswith('.tar.gz'):
            extract_tar(response.content, '.tar.gz')
        elif url_base.endswith('.tar.xz'):
            extract_tar(response.content, '.tar.xz')
        elif url_base.endswith('.tar'):
            extract_tar(response.content, '.tar')
        elif url_base.endswith('PKGBUILD'):
            with open(os.path.join(path, 'PKGBUILD'), 'wb') as file:
                file.write(response.content)
        else:
            print('Incorrect remote type')
            sys.exit(1)
    else:
        print('Failed to download remote: ' + url)
        sys.exit(1)

def pkg_build(args):
    ''' Build package '''
    cmd = [
        '/usr/bin/makepkg', '--config', MAKEPKGCFG,
        '--noconfirm', '--log', '--syncdeps'
    ]

    if not args.noforce:
        cmd.append('--force')

    if args.nosign:
        cmd.append('--nosign')
    else:
        cmd.append('--sign')

    if args.pkg:
        cmd.append('--pkg')
        cmd.append(','.join(args.pkg))

    try:
        subprocess.check_call(cmd)
    except subprocess.CalledProcessError as error:
        print('Failed to build package!')
        error_print_exit(error)

def main():
    ''' Main '''
    print_separator()

    # Handle zombie processes
    signal.signal(signal.SIGCHLD, signal_handle_sigchld)

    # Parse arguments
    args = args_parse()

    # Initialize paxd
    paxd_initialize()

    # Upgrade databases and packages
    pacman_upgrade()

    if args.gpginit:
        print_separator()
        gpg_init()
        sys.exit(0)
    elif args.dbreset:
        print_separator()
        db_update(args)
        sys.exit(0)
    elif args.pkgcleanup:
        print_separator()
        packages_cleanup(PKGDEST, args.db)
        sys.exit(0)

    # Clean builddir
    if not args.noclean:
        path_clean(BUILDDIR)

    # cd to PKGBUILD root
    os.chdir(PKGBUILD)

    # Clean pkgbuild directory
    path_clean(PKGBUILD)

    # Prepare
    print_separator()
    if args.local:
        prepare_local(args.local)
    elif args.git:
        prepare_git(args.git, PKGBUILD)
    elif args.aur:
        prepare_aur(args.aur)
    elif args.remote:
        prepare_remote(args.remote, PKGBUILD)
    else:
        print('Argument error')
        sys.exit(1)

    # cd to specified relpath
    if args.path and not args.local:
        os.chdir(os.path.join(PKGBUILD, args.path))
        print('Successfully changed directory to ' + args.path)

    # Build package
    print_separator()
    pkg_build(args)

    # Create Database
    if args.db:
        # gpg hack: sign error EOF otherwise
        gpg_hack()

        print_separator()
        db_update(args)

if __name__ == '__main__':
    main()
