''' Container '''

from collections import OrderedDict
import json
import os

import yaml

from utils import meta, string, api

__all__ = ['CONTAINERS', 'META', 'get_existing', 'backups_rename', 'backups_cleanup']


def config_parse():
    ''' containers.yaml '''
    load = yaml.load(open(os.path.join(meta.PATH_REPO, 'containers.yaml')), Loader=yaml.CLoader)
    load_meta = load['Meta']
    del load['Meta']
    meta.dict_merge_add(load_meta, meta.META)
    return load, load_meta


class Container:
    ''' Container '''
    # pylint: disable=too-many-arguments
    def __init__(self, basename, name=None, config=None,
                 identity=None, path_basename=False, command=None):
        self.basename = basename
        self.name = name if name else string.add_uuid(self.basename)
        self.config = config
        self.identity = identity
        self.path = os.path.join(META['BindRoot'], self.basename if path_basename else self.name)
        self.command = command

        if self.config:
            self._config()
    # pylint: enable=too-many-arguments

    def _config(self):
        ''' Finalize config '''
        if 'UGID' not in self.config:
            raise RuntimeError('UGID not in config: {0:s}'.format(self.name))
        if 'Names' in self.config:
            self.config['Active'] = self.config['Names'] is not None and \
                self.name in self.config['Names']
            del self.config['Names']
        else:
            self.config['Active'] = False

        for key in ('Create', 'Setup'):
            if key not in self.config:
                continue
            config = self.config[key]

            meta.dict_merge_add(config, {'Hostname': self.name, 'Image': self.config['Image']})
            if self.command:
                meta.dict_merge(config, {'Cmd': self.command})
            meta.dict_merge_add(config, META['Default'])

            if 'HostConfig' in config:
                host_config = config['HostConfig']
                if 'Binds' in host_config:
                    self._config_binds(host_config['Binds'])
                if 'Devices' in host_config:
                    self._config_devices(host_config['Devices'])
                if 'Tmpfs' in host_config:
                    self._config_tmpfs(host_config['Tmpfs'])

        if 'Paths' in self.config:
            self._config_paths(self.config['Paths'])

    def _config_paths(self, paths):
        ''' Convert relative paths into absolute '''
        for path, value in paths.items():
            if os.path.isabs(path):
                value['Absolute'] = True
            else:
                value['Absolute'] = False
                paths[os.path.join(self.path, path)] = value
                del paths[path]

            value['Type'] = value.get('Type', 'Directory')

    def _config_binds(self, binds):
        ''' Convert relative binds into absolute '''
        for index, bind in enumerate(binds):
            bind = bind.split(':')
            if not os.path.isabs(bind[0]):
                bind[0] = os.path.join(self.path, bind[0])
                binds[index] = ':'.join(bind)

    def _config_devices(self, devices):
        ''' Convert devices paths into real '''
        for dictionary in devices:
            if not os.path.isabs(dictionary['PathOnHost']):
                dictionary['PathOnHost'] = os.path.join(self.path, dictionary['PathOnHost'])
            dictionary['PathOnHost'] = os.path.realpath(dictionary['PathOnHost'])

            if not dictionary['PathInContainer']:
                dictionary['PathInContainer'] = dictionary['PathOnHost']

    def _config_tmpfs(self, tmpfs_dict):
        ''' Add Tmpfs options '''
        for path, options in tmpfs_dict.items():
            option_dict = OrderedDict()
            for option in options.split(','):
                option = option.split('=')
                length = len(option)
                if length == 1:
                    option_dict[option[0]] = None
                elif length == 2:
                    option_dict[option[0]] = option[1]
                else:
                    raise RuntimeError(
                        'tmpfs option has more than one equal sign: {0:s}'.format(str(option)))

            if 'uid' not in option_dict:
                option_dict['uid'] = str(self.config['UGID'])
            if 'gid' not in option_dict:
                option_dict['gid'] = str(self.config['UGID'])

            options = []
            for option, value in option_dict.items():
                if value is None:
                    options.append(option)
                else:
                    options.append('{0:s}={1:s}'.format(option, value))
            tmpfs_dict[path] = ','.join(options)


    def attach(self):
        ''' Attach '''
        return api.request(api.post, '/containers/{0:s}/attach'.format(self.identity),
                           {'logs': True, 'stream': True, 'stdout': True, 'stderr': True},
                           stream=True)

    def create_setup(self):
        ''' Setup '''
        response = api.request(api.post, '/containers/create', {'name': self.name},
                               json.dumps(self.config['Setup']))
        self.identity = response.json()['Id']

    def create(self):
        ''' Create '''
        response = api.request(api.post, '/containers/create', {'name': self.name},
                               json.dumps(self.config['Create']))
        self.identity = response.json()['Id']

    def inspect(self):
        ''' Inspect '''
        return api.request(api.get, '/containers/{0:s}/json'.format(self.identity)).json()

    def orphan(self):
        ''' Orphan? '''
        inspect = self.inspect()
        return inspect['Config']['Image'] not in api.image_inspect(inspect['Image'])['RepoTags']

    def _paths_create(self):
        ''' Create paths '''
        log = ''
        if not os.path.exists(self.path):
            log += meta.run(['/usr/bin/btrfs', 'subvolume', 'create', self.path])
            log += meta.run(['/usr/bin/chmod', 'u=rwx,g=rx,o=', self.path])
            log += 'Subvolume created: {0:s}\n'.format(self.path)

        paths_new = set()
        for path, value in sorted(self.config['Paths'].items()):
            if not os.path.exists(path):
                if value['Absolute']:
                    raise RuntimeError(log + 'Path does not exist: {0:s}'.format(path))

                if value['Type'] == 'Directory':
                    if 'Subvolume' in value and value['Subvolume']:
                        path_dir = os.path.dirname(path)
                        try:
                            os.makedirs(path_dir)
                        except FileExistsError:
                            pass
                        else:
                            log += 'Directories created: {0:s}\n'.format(path_dir)
                        log += meta.run(['/usr/bin/btrfs', 'subvolume', 'create', path])
                        log += 'Subvolume created: {0:s}\n'.format(path)
                    else:
                        os.makedirs(path)
                        log += 'Directories created: {0:s}\n'.format(path)

                    if 'Attributes' in value and value['Attributes']:
                        log += meta.run(['/usr/bin/chattr', value['Attributes'], path])
                        log += 'Attributes changed: {0:s}: {1:s}\n'.format(
                            path, value['Attributes'])

                    paths_new.add(path)
                else:
                    log += 'Path was not created: {0:s}\n'.format(path)

        if not paths_new:
            log += 'No paths created\n'
        return log, paths_new

    def _paths_permissions(self, paths_new, permissions):  # pylint: disable=too-many-branches
        ''' Paths permissions '''
        if not permissions and not paths_new:
            return 'No permissions to enforce\n'

        log = ''
        for path, value in sorted(self.config['Paths'].items()):
            if not permissions and path not in paths_new:
                log += 'Skipping path: {0:s}\n'.format(path)
                continue

            user = value['User'] if 'User' in value else self.config['UGID']
            group = value['Group'] if 'Group' in value else self.config['UGID']

            if 'Exclude' in value:
                log += 'Path: {0:s}\n'.format(path)
                log += meta.chown([path], user, group)
                log += meta.chmod([path], value['Mode'])
                if 'ACL' in value:
                    log += meta.setfacl([path], value['ACL'])
                else:
                    log += meta.setfacl([path])

                if value['Exclude'] == '*':
                    paths = []
                else:
                    paths = meta.paths_include(path, value['Exclude'])
            else:
                paths = [path]

            if paths:
                log += 'Paths: {0:s}\n'.format(' '.join(paths))
                log += meta.chown(paths, user, group, recursive=True)
                log += meta.chmod(paths, value['Mode'], recursive=True)
                if 'ACL' in value:
                    log += meta.setfacl(paths, value['ACL'], recursive=True)
                else:
                    log += meta.setfacl([path], recursive=True)
            else:
                log += 'No paths: {0:s}\n'.format(path)
        return log

    def paths(self, permissions=False):
        ''' Paths creation and permissions '''
        log = ''
        try:
            log += 'Creating paths\n'
            log_ret, paths_new = self._paths_create()
            log += log_ret
            log += 'Path permissions\n'
            log += self._paths_permissions(paths_new, permissions)
        except RuntimeError as error:
            raise RuntimeError(log + str(error))
        return log

    def remove(self):
        ''' Remove '''
        api.request(api.delete, '/containers/{0:s}'.format(self.identity))
        self.identity = None

    def rename(self, name):
        ''' Rename to name'''
        api.request(api.post, '/containers/{0:s}/rename'.format(self.identity), {'name': name})
        self.name = name

    def start(self):
        ''' Start '''
        api.request(api.post, '/containers/{0:s}/start'.format(self.identity))

    def start_systemd(self):
        ''' Start via systemd '''
        meta.run(['/usr/bin/systemctl', 'start', '{0:s}{1:s}'.format(
            META['SystemdPrefix'], self.name)])

    def stop(self):
        ''' Stop '''
        api.request(api.post, '/containers/{0:s}/stop'.format(self.identity))

    def stop_systemd(self):
        ''' Stop via systemd '''
        meta.run(['/usr/bin/systemctl', 'stop', '{0:s}{1:s}'.format(
            META['SystemdPrefix'], self.name)])


def get_existing():
    ''' get existing containers '''
    return [
        (value['Names'][0][1:] if value['Names'][0].startswith('/') else value['Names'][0],
         value['Id'])
        for value in api.request(api.get, '/containers/json', {'all': 'True'}).json()
    ]


def backups_rename(name, containers):
    ''' Rename backups '''
    renamed = []
    for backup in reversed(containers):
        name_new = string.backup_incr(name, backup.name)
        renamed.append((backup.name, name_new))
        backup.rename(name_new)
    return renamed


def backups_cleanup(name, containers):
    ''' Cleanup backups '''
    removed = []
    for backup in reversed(containers):
        if string.backup_old(name, backup.name):
            backup.remove()
            removed.append(backup.name)
        else:
            break
    return removed


CONTAINERS, META = config_parse()
