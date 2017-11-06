''' Image '''

import os
import re
from typing import Any, Dict, Tuple

import yaml

from utils import meta


__all__ = ['IMAGES', 'META', 'path_image']


def config_parse() -> Tuple[Dict[str, Any], Dict[str, Any]]:
    ''' images.yml '''
    load = yaml.load(  # type: ignore
        open(os.path.join(meta.PATH_REPO, 'images.yml')), Loader=yaml.CLoader)
    load_meta = load['Meta']
    del load['Meta']
    return load, load_meta


def path_image(name: str) -> str:
    ''' Path to image '''
    base, name, tag = re.split(r'[/:]', name)
    return os.path.join(meta.PATH_REPO, META['Paths'][base], name, tag)  # type: ignore


def path_dockerfile(name: str) -> str:
    ''' Path to dockerfile '''
    return os.path.join(path_image(name), 'Dockerfile')


IMAGES, META = config_parse()
