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
            del self.config['Names']
        if 'Paths' in self.config:
            self._config_paths(self.config['Paths'])

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

    def _config_paths(self, paths):
        ''' Convert relative paths into absolute '''
        for path, values in paths.items():
            if not os.path.isabs(path):
                paths[os.path.join(self.path, path)] = values
                del paths[path]

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

    def permissions(self):
        ''' Enforce permissions '''
        log = ''
        for path, values in self.config['Paths'].items():
            if not os.path.isabs(path):
                path = os.path.join(self.path, path)
            user = values['User'] if 'User' in values else self.config['UGID']
            group = values['Group'] if 'Group' in values else self.config['UGID']

            if not os.path.exists(path):
                raise RuntimeError('Path does not exist: {0:s}'.format(path))

            if 'Exclude' in values:
                log += 'Path: {0:s}\n'.format(path)
                log += meta.chown([path], user, group)
                log += meta.chmod([path], values['Mode'])
                if 'ACL' in values:
                    log += meta.setfacl([path], values['ACL'])
                else:
                    log += meta.setfacl([path])

                paths = meta.paths_include(path, values['Exclude'])
            else:
                paths = [path]

            if paths:
                log += 'Paths: {0:s}\n'.format(' '.join(paths))
                log += meta.chown(paths, user, group, recursive=True)
                log += meta.chmod(paths, values['Mode'], recursive=True)
                if 'ACL' in values:
                    log += meta.setfacl(paths, values['ACL'], recursive=True)
                else:
                    log += meta.setfacl([path], recursive=True)
            else:
                log += 'No paths: {0:s}\n'.format(path)
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
        (values['Names'][0][1:] if values['Names'][0].startswith('/') else values['Names'][0],
         values['Id'])
        for values in api.request(api.get, '/containers/json', {'all': 'True'}).json()
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
