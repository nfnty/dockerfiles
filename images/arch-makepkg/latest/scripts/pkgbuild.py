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
        '--local', action='store_true',
        help='Build from local path'
    )
    method.add_argument(
        '--aur', metavar='NAME',
        help='Build from AUR'
    )
    method.add_argument(
        '--git', metavar='URL',
        help='Build from remote git repository'
    )
    method.add_argument(
        '--remote', metavar='URL',
        help='Build from remote PKGBUILD, directory or archive (tar, gz or xz)'
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
        '--noclean', action='store_true', default=False,
        help='Do not clean builddir'
    )
    parser.add_argument(
        '--nosign', action='store_true', default=False,
        help='Do not sign package(s) and database',
    )
    parser.add_argument(
        '--noforce', action='store_true', default=False,
        help='Do not force overwrite old package',
    )

    # Positional
    parser.add_argument(
        'path', metavar='PATH', nargs='?',
        help='Optional path to PKGBUILD directory',
    )

    args = parser.parse_args()

    # AUR and PATH are mutually exclusive
    if args.aur and args.path:
        print('--aur and PATH are mutually exclusive\n')
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

def print_separator():
    ''' Prints a separator for redability '''
    print('\n##################################################\n')

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
                '/usr/bin/find', path,
                '-mindepth', '1', '-delete'
            ]
        )
    except subprocess.CalledProcessError as error:
        print('Failed to clean ' + path)
        error_print_exit(error)

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
def db_create(args):
    ''' Create database '''
    path_db = os.path.join(PKGDEST, args.db + '.db.tar.xz')

    cmd_find = ['/usr/bin/find', PKGDEST, '-name', '*.pkg.tar.xz', '-print0']

    try:
        os.stat(path_db)
        cmd_find.insert(-1, '-newer')
        cmd_find.insert(-1, path_db)
    except FileNotFoundError:
        pass

    try:
        packages = subprocess.check_output(cmd_find).decode('UTF-8').split('\0')[:-1]
    except subprocess.CalledProcessError as error:
        print('db creation: find failed!')
        error_print_exit(error)

    cmd_repo = ['/usr/bin/repo-add', path_db]

    if not args.nosign:
        cmd_repo.insert(1, '--sign')

    if packages:
        cmd_repo += packages
    else:
        print('db creation: Failed to find packages')
        sys.exit(1)
        return

    try:
        subprocess.check_call(cmd_repo)
    except subprocess.CalledProcessError as error:
        print('Failed to create db!')
        error_print_exit(error)

def extract(content, extension):
    ''' Extract compressed tar archive '''
    # Check extension
    if extension == 'gz':
        method = '--gzip'
    elif extension == 'xz':
        method = '--xz'
    else:
        print('ERROR: Wrong extension')
        sys.exit(1)

    p_tar = subprocess.Popen(
        [
            '/usr/bin/tar', '--extract', method, '--strip-components=1', '--file=-'
        ],
        stdin=subprocess.PIPE
    )
    p_tar.stdin.write(content)
    p_tar.stdin.close()
    p_tar.wait(30)
    if p_tar.poll() == 0:
        print('.tar.' + extension + ' archive extracted')
    else:
        print('.tar.' + extension + ' extract failed')
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
        extract(response.content, 'gz')
    else:
        print('Failed to download archive')
        sys.exit(1)
def prepare_remote(args, path):
    ''' Prepare remote pkgbuild directory '''
    try:
        response = requests.get(args.remote)
    except requests.ConnectionError as error:
        print('Failed to download sources')
        error_print_exit(error)

    if response.ok:
        print('Successfully downloaded: ' + args.remote)

        if args.remote.endswith('.tar.gz'):
            extract(response.content, 'gz')
        elif args.remote.endswith('.tar.xz'):
            extract(response.content, 'xz')
        elif args.remote.rsplit('?')[0].endswith('PKGBUILD'):
            with open(os.path.join(path, 'PKGBUILD'), 'wb') as file:
                file.write(response.content)
        else:
            print('Incorrect remote type')
            sys.exit(1)
    else:
        print('Failed to download remote: ' + args.remote)
        sys.exit(1)

def main():
    ''' Main '''
    # Handle zombie processes
    signal.signal(signal.SIGCHLD, signal_handle_sigchld)

    # Parse arguments
    args = args_parse()

    # Initialize paxd
    paxd_initialize()

    # Upgrade databases and packages
    pacman_upgrade()

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
        print('Successfully changed directory')

    # Build package
    print_separator()
    pkg_build(args)

    # Create Database
    if args.db:
        # gpg hack: sign error EOF otherwise
        gpg_hack()

        print_separator()
        db_create(args)

if __name__ == '__main__':
    main()
