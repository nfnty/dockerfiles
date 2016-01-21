#!/usr/bin/python3
''' Check image package versions '''

import distutils.version
import os
import re
import subprocess

import lxml.html
import requests
import yaml

PATH_REPO = subprocess.run([
    '/usr/bin/git', '-C', os.path.dirname(os.path.realpath(__file__)),
    'rev-parse', '--show-toplevel'
], stdout=subprocess.PIPE, check=True).stdout.decode('UTF-8').rstrip('\n')

IMAGES = yaml.load(open(os.path.join(PATH_REPO, 'images.yaml')), Loader=yaml.CLoader)
META = IMAGES['meta']
del IMAGES['meta']


def print_spacer():
    ''' Print spacer '''
    print('\n######################################\n')


def print_version(source, version):
    ''' Print version '''
    print(format('{0:15s}{1:s}'.format(source, version)))


def path_image(image):
    ''' return path to image '''
    base, name, tag = re.split(r'[/:]', image)
    return os.path.join(PATH_REPO, META['paths'][base], name, tag)


def fetch(url, headers, timeout):
    ''' Fetch URL '''
    try:
        response = requests.get(url, headers=headers, timeout=timeout)
    except requests.exceptions.Timeout as error:
        raise RuntimeError('fetch timeout: {0:s}\n'.format(str(error)))
    if response.status_code != 200:
        raise RuntimeError('fetch status_code: {0:d}: {1:s}'.format(
            response.status_code, response.content.decode('UTF-8').rstrip()))
    return lxml.html.document_fromstring(response.content)


def document_parse(document, xpath, attribute, regex):
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
            obj = re.search(regex, string)
            if not obj:
                continue
            elif len(obj.groups()) > 1:
                raise RuntimeError('Incorrect regex: More than 1 capture group')
            string = obj.group(1)

        versions.append(distutils.version.LooseVersion(string))

    if not versions:
        raise RuntimeError('Incorrect regex: No match')

    return sorted(versions, reverse=True)[0]


def version_scrape(url, xpath, attribute, regex):
    ''' Scrape latest version from url '''
    document = fetch(url, META['headers'], META['limits']['timeout'])
    return document_parse(document, xpath, attribute, regex)


def version_pacman(package):
    ''' Return dict with repository versions of package '''
    try:
        output = subprocess.run([
            '/usr/bin/expac', '--sync', '--search', '%r %v', r'^{0:s}$'.format(re.escape(package))
        ], check=True, stdout=subprocess.PIPE).stdout.decode('UTF-8')
    except subprocess.CalledProcessError:
        raise RuntimeError('{0:s} not in any repository'.format(package))

    versions = {}
    for line in output.splitlines():
        repo, version = line.split()
        versions[repo] = distutils.version.LooseVersion(version)
    return versions


def dockerfile_update(path, variable, version):
    ''' Update Dockerfiles with current version '''
    with open(path, 'r') as filedesc:
        newfile, found = re.subn(
            r'{0:s}=\'\S*\''.format(variable),
            '{0:s}=\'{1:s}\''.format(variable, version),
            filedesc.read(),
        )

    if not found:
        raise ValueError('Did not find ENV variable')
    elif found > 1:
        raise ValueError('More than 1: {0:s}'.format(variable))

    with open(path, 'w') as filedesc:
        filedesc.write(newfile)


def main():
    ''' Main '''
    subprocess.check_call(['/usr/bin/sudo', '/usr/bin/pacman', '--sync', '--refresh'])

    print_spacer()

    for image, image_dict in IMAGES.items():
        print('\n{0:s}'.format(image))
        if 'check' in image_dict and not image_dict['check']:
            print('Not checked!')
            continue

        if 'packages' in image_dict:
            for package, package_dict in image_dict['packages'].items():
                print('\033[32m{0:s}\033[0m:'.format(package))

                for source, source_dict in package_dict['sources'].items():
                    source_dict['version'] = version_scrape(
                        source_dict['url'],
                        source_dict['xpath'],
                        source_dict['attribute'] if 'attribute' in source_dict else None,
                        source_dict['regex'] if 'regex' in source_dict else None,
                    )

                try:
                    for repo, version in version_pacman(package).items():
                        package_dict['sources'][repo] = {'version': version}
                except RuntimeError as error:
                    print(error)

                for source, source_dict in package_dict['sources'].items():
                    print_version(source, source_dict['version'].vstring)

                dockerfile_update(
                    os.path.join(path_image(image), 'Dockerfile'),
                    package_dict['variable'],
                    package_dict['sources'][package_dict['download']]['version'].vstring,
                )

    print_spacer()

if __name__ == '__main__':
    main()
