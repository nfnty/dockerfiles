''' Image '''

import os
import re

import yaml

from utils import meta


__all__ = ['IMAGES', 'META', 'path_image']


def config_parse():
    ''' images.yml '''
    load = yaml.load(open(os.path.join(meta.PATH_REPO, 'images.yml')), Loader=yaml.CLoader)
    load_meta = load['Meta']
    del load['Meta']
    return load, load_meta


def path_image(name):
    ''' Path to image '''
    base, name, tag = re.split(r'[/:]', name)
    return os.path.join(meta.PATH_REPO, META['Paths'][base], name, tag)


def path_dockerfile(name):
    ''' Path to dockerfile '''
    return os.path.join(path_image(name), 'Dockerfile')


IMAGES, META = config_parse()
