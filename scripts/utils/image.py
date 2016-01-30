''' Image '''


import os
import re

import yaml

from utils import meta, api

__all__ = ['IMAGES', 'META', 'path_image', 'dockerfile_from']


def config_parse():
    ''' images.yaml '''
    load = yaml.load(open(os.path.join(meta.PATH_REPO, 'images.yaml')), Loader=yaml.CLoader)
    load_meta = load['Meta']
    del load['Meta']
    meta.dict_merge(load_meta, meta.META)
    return load, load_meta

IMAGES, META = config_parse()


class Image:
    ''' Image '''
    def __init__(self, name, config):
        self.name = name
        self.config = config

        self.path = path_image(self.name)
        if self.config:
            self._config()

    def _config(self):
        ''' Finalize config '''

        if 'Scratch' in self.config and not os.path.isabs(self.config['Scratch'][0]):
            self.config['Scratch'][0] = os.path.join(meta.PATH_REPO, self.config['Scratch'][0])

    def _tar(self):
        ''' Tar image directory '''
        return meta.run_pipe([
            '/usr/bin/tar', '--create', '--file=-',
            '--owner=root', '--group=root',
            '--directory={0:s}'.format(self.path),
            '.',
        ]).stdout

    def build_scratch(self):
        ''' Build scratch '''
        return meta.run(self.config['Scratch'])

    def build(self, nocache):
        ''' Build image '''
        return api.request(
            api.post, '/build',
            {'t': self.name, 'nocache': nocache, **META['Params']},
            headers={'Content-Type': 'application/tar'},
            data=self._tar(),
            stream=True
        )


def path_image(name):
    ''' Path to image '''
    base, name, tag = re.split(r'[/:]', name)
    return os.path.join(meta.PATH_REPO, META['Paths'][base], name, tag)


def path_dockerfile(name):
    ''' Path to dockerfile '''
    return os.path.join(path_image(name), 'Dockerfile')


def dockerfile_from(name):
    ''' image FROM '''
    with open(path_dockerfile(name)) as filedesc:
        for line in filedesc:
            if line.startswith('FROM'):
                return line.split()[-1]
