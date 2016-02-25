''' Meta '''

from copy import deepcopy
import subprocess
import sys
import os

from termcolor import cprint
import yaml

__all__ = [
    'PATH_REPO', 'META',
    'failed',
    'dict_merge', 'dict_merge_copy',
    'run', 'chmod', 'chown', 'setfacl',
    'paths_include',
]


def path_repo():
    ''' Repository path '''
    path = run_pipe([
        '/usr/bin/git', '-C', os.path.dirname(os.path.realpath(__file__)),
        'rev-parse', '--show-toplevel'
    ]).stdout.decode('UTF-8').rstrip('\n')
    return path


def yaml_meta():
    ''' meta.yaml '''
    meta = yaml.load(open(os.path.join(PATH_REPO, 'meta.yaml')), Loader=yaml.CLoader)
    meta['BackupPrefixLen'] = len(meta['BackupPrefix'])
    meta['SystemdPrefixLen'] = len(meta['SystemdPrefix'])
    return meta


def failed(string):
    ''' Print string and exit '''
    cprint(string, 'red', file=sys.stderr)
    sys.exit(1)


def dict_merge(dict_dst, dict_src):
    ''' Merge src into dst, overwriting, appending '''
    if dict_src is None:
        return
    if dict_dst is None:
        dict_dst = deepcopy(dict_src)
        return
    for key, value in dict_src.items():
        if key in dict_dst:
            if type(dict_dst[key]) is type(value) or dict_dst[key] is None or value is None:
                if isinstance(dict_dst[key], dict):
                    dict_merge(dict_dst[key], value)
                elif isinstance(dict_dst[key], list) or isinstance(dict_dst[key], tuple):
                    dict_dst[key] += value
                elif isinstance(dict_dst[key], set):
                    dict_dst[key] |= value
                else:
                    dict_dst[key] = deepcopy(value)
            else:
                raise RuntimeError(
                    'Type mismatch: {0:s}: {1:s}: {2:s} <- {3:s}: {4:s}'.format(
                        key,
                        str(type(dict_dst[key])), str(dict_dst[key]),
                        str(type(value)), str(value)),
                )
        else:
            dict_dst[key] = deepcopy(value)


def dict_merge_add(dict_dst, dict_src):
    ''' Merge src into dst, no overwriting, no appending'''
    if dict_src is None:
        return
    if dict_dst is None:
        dict_dst = deepcopy(dict_src)
        return
    for key, value in dict_src.items():
        if key in dict_dst:
            if type(dict_dst[key]) is type(value) or dict_dst[key] is None or value is None:
                if isinstance(dict_dst[key], dict):
                    dict_merge_add(dict_dst[key], value)
            else:
                raise RuntimeError(
                    'Type mismatch: {0:s}: {1:s}: {2:s} <- {3:s}: {4:s}'.format(
                        key,
                        str(type(dict_dst[key])), str(dict_dst[key]),
                        str(type(value)), str(value)),
                )
        else:
            dict_dst[key] = deepcopy(value)


def dict_merge_copy(dict_dst, dict_src):
    ''' Merge src into dst, no overwriting, return new dict '''
    dict_dst_new = deepcopy(dict_dst)
    dict_merge(dict_dst_new, dict_src)
    return dict_dst_new


def dict_merge_add_copy(dict_dst, dict_src):
    ''' Merge src into dst, no overwriting, no appending, return new dict '''
    dict_dst_new = deepcopy(dict_dst)
    dict_merge_add(dict_dst_new, dict_src)
    return dict_dst_new


def run(command):
    ''' Run command '''
    try:
        process = subprocess.run(
            command, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as error:
        raise RuntimeError('{0:s}\n{1:s}'.format(str(error), error.stdout.decode('UTF-8')))
    return process.stdout.decode('UTF-8')


def run_pipe(command):
    ''' Run command, return CompletedProcess '''
    try:
        process = subprocess.run(
            command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as error:
        raise RuntimeError('{0:s}\n{1:s}\n{2:s}'.format(
            str(error), error.stdout.decode('UTF-8'), error.stderr.decode('UTF-8')))
    return process


def chown(paths, user, group, recursive=False):
    ''' Change path ownership '''
    command = ['/usr/bin/chown', '--changes', '{0:s}:{1:s}'.format(str(user), str(group))] + paths
    if recursive:
        command[2:2] = ['--recursive']
    return run(command)


def chmod(paths, mode, recursive=False):
    ''' Change path mode '''
    command = ['/usr/bin/chmod', '--changes', mode] + paths
    if recursive:
        command[2:2] = ['--recursive']
    return run(command)


def setfacl(paths, acl_spec=None, recursive=False):
    ''' Set path access control lists '''
    command = ['/usr/bin/setfacl', '--remove-all']
    if acl_spec:
        command += ['--modify', acl_spec]
    if recursive:
        command[1:1] = ['--recursive']
    command += paths
    return run(command)


def paths_include(path, excludes):
    ''' Paths to include '''
    included = []
    excludes = excludes.copy()
    for root, directories, filenames in os.walk(path):
        for directory in directories.copy():
            path_full = os.path.join(root, directory)
            path_rel = os.path.relpath(path_full, path)
            for exclude in excludes:
                if exclude == path_rel:
                    directories.remove(directory)
                    excludes.remove(exclude)
                    break
                elif exclude.startswith(path_rel + os.path.sep):
                    break
            else:
                directories.remove(directory)
                included.append(path_full)

        for filename in filenames:
            path_full = os.path.join(root, filename)
            path_rel = os.path.relpath(path_full, path)
            for exclude in excludes:
                if exclude == path_rel:
                    excludes.remove(exclude)
                    break
            else:
                included.append(path_full)

    return included


PATH_REPO = path_repo()
META = yaml_meta()
