#!/usr/bin/python3
''' Check image package versions '''

import argparse
import distutils.version
import re
import subprocess
from typing import Any, Dict, Sequence, Tuple

import lxml.html  # type: ignore
import requests
from termcolor import cprint

from utils.image import IMAGES, path_dockerfile


TIMEOUT = (31, 181)  # (Connect, Read)
HEADERS = {'user-agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0'}


def args_parse(arguments: Sequence[str] = None) -> argparse.Namespace:
    ''' Parse arguments '''
    par0 = argparse.ArgumentParser(description='Image package version checker')

    method = par0.add_mutually_exclusive_group(required=False)
    method.add_argument(
        '--include', metavar='IMAGE', action='append', choices=IMAGES.keys(),
        help='Include image(s)',
    )
    method.add_argument(
        '--exclude', metavar='IMAGE', action='append', choices=IMAGES.keys(),
        help='Exclude image(s)',
    )

    return par0.parse_args(arguments)


def fetch(url: str, timeout: Tuple[int, int]) -> Any:
    ''' Fetch URL '''
    try:
        response = requests.get(url, headers=HEADERS, timeout=timeout)
        response.raise_for_status()
    except (requests.exceptions.Timeout, requests.exceptions.HTTPError) as error:
        raise RuntimeError('fetch: {0:s}\n{1:s}'.format(str(error), str(error.response.content)))
    except OSError as error:
        raise RuntimeError('fetch: {0:s}'.format(str(error)))
    return lxml.html.document_fromstring(response.content)


def document_parse(document: Any, xpath: str, attribute: str,
                   regex: str) -> distutils.version.LooseVersion:
    ''' xpath version extractor '''
    nodes = document.xpath(xpath)
    if not nodes:
        raise RuntimeError('Incorrect xpath: No nodes')

    versions = []
    for node in nodes:
        if attribute:
            string = node.get(attribute)
        elif isinstance(node, str):
            string = node
        else:
            string = node.text

        if regex:
            obj = re.search(regex, string,
                            flags=(re.MULTILINE | re.DOTALL))  # pylint: disable=no-member
            if not obj:
                continue
            elif len(obj.groups()) > 1:
                raise RuntimeError('Incorrect regex: More than 1 capture group')
            string = obj.group(1)
            if not string:
                raise RuntimeError('Incorrect regex: Invalid capture group')

        versions.append(distutils.version.LooseVersion(string))

    if not versions:
        raise RuntimeError('No matching versions')

    version: distutils.version.LooseVersion = sorted(versions, reverse=True)[0]
    if not version or not hasattr(version, 'vstring'):
        raise RuntimeError('Version is invalid')

    return version


def version_scrape(url: str, xpath: str, attribute: str,
                   regex: str) -> distutils.version.LooseVersion:
    ''' Scrape latest version from url '''
    document = fetch(url, TIMEOUT)
    return document_parse(document, xpath, attribute, regex)


def version_pacman(package: str) -> Dict[str, distutils.version.LooseVersion]:
    ''' Return dict with repository versions of package '''
    try:
        output = subprocess.run([
            '/usr/bin/expac', '--sync', '--search',
            '%n %r %v',
            r'^{0:s}$'.format(re.escape(package)),
        ], check=True, stdout=subprocess.PIPE).stdout.decode('UTF-8')
    except subprocess.CalledProcessError:
        raise RuntimeError('{0:s} not in any repository'.format(package))

    versions: Dict[str, distutils.version.LooseVersion] = {}
    for line in output.splitlines():
        name, repo, version = line.split()
        if name == package:
            versions[repo] = distutils.version.LooseVersion(version)
    return versions


def dockerfile_update(path: str, variable: str, version: str) -> None:
    ''' Update Dockerfiles with current version '''
    with open(path, 'r') as fobj:
        newfile, found = re.subn(
            r'{0:s}=\'\S*\''.format(variable),
            '{0:s}=\'{1:s}\''.format(variable, version),
            fobj.read(),
        )

    if not found:
        raise ValueError('Did not find ENV variable')
    elif found > 1:
        raise ValueError('More than 1: {0:s}'.format(variable))

    with open(path, 'w') as fobj:
        fobj.write(newfile)


def main() -> None:  # pylint: disable=too-many-branches
    ''' Main '''
    subprocess.check_call(['/usr/bin/sudo', '/usr/bin/pacman', '--sync', '--refresh'])

    if ARGS.include:
        images = {image: config for image, config in IMAGES.items() if image in ARGS.include}
    elif ARGS.exclude:
        images = {image: config for image, config in IMAGES.items() if image not in ARGS.exclude}
    else:
        images = IMAGES

    for image, image_dict in sorted(images.items(), key=lambda item: item[0]):
        cprint('\n{0:s}'.format(image), 'white', attrs=['underline'])
        if 'Check' in image_dict and not image_dict['Check']:
            print('Not checked!')
            continue
        if 'Packages' not in image_dict:
            print('No packages!')
            continue

        for package, package_dict in image_dict['Packages'].items():
            cprint('{0:s}:'.format(package), 'yellow')

            for source, source_dict in package_dict['Sources'].items():
                try:
                    source_dict['Version'] = version_scrape(
                        source_dict['URL'],
                        source_dict['XPath'],
                        source_dict['Attribute'] if 'Attribute' in source_dict else None,
                        source_dict['Regex'] if 'Regex' in source_dict else None,
                    )
                except RuntimeError as error:
                    cprint('{0:s}: {1:s}'.format(source, str(error)), 'red')
                    source_dict['Version'] = None

            try:
                for repo, version in version_pacman(package).items():
                    package_dict['Sources'][repo] = {'Version': version}
            except RuntimeError as error:
                cprint(str(error), 'red')

            for source, source_dict in package_dict['Sources'].items():
                print('{0:15s}{1:s}'.format(
                    source,
                    source_dict['Version'].vstring if source_dict['Version'] else 'None',
                ))

            if not package_dict['Sources'][package_dict['Download']]['Version']:
                cprint('No Version for Download: {0:s}'.format(
                    package_dict['Download']), 'red')
                continue

            dockerfile_update(
                path_dockerfile(image),
                package_dict['Variable'],
                package_dict['Sources'][package_dict['Download']]['Version'].vstring,
            )


if __name__ == '__main__':
    ARGS = args_parse()
    main()
