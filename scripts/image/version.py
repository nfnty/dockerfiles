#!/usr/bin/python3
''' Check image package versions '''
import distutils.version
import lxml.html
import os
import re
import requests
import subprocess
import yaml

os.chdir(os.path.dirname(os.path.realpath(__file__)))
REPODIR = subprocess.check_output([
    '/usr/bin/git', 'rev-parse', '--show-toplevel'
]).decode('UTF-8').strip()
IMAGEDIR = os.path.join(REPODIR, 'images')

CONFIG = yaml.load(open(os.path.join(REPODIR, 'images.yaml')), Loader=yaml.CLoader)
META = CONFIG['meta']
IMAGES = CONFIG.copy()
del IMAGES['meta']
del CONFIG

def print_spacer():
    ''' Print spacer '''
    print('\n######################################\n')
def print_version(source, version):
    ''' Print version '''
    print(format('{0:15s}{1:s}'.format(source, version)))

def scrape(url, xpath, attribute, regex):
    ''' Scrape latest version from url '''
    document = lxml.html.document_fromstring(requests.get(url, headers=META['headers']).content)

    nodes = document.xpath(xpath)
    if not nodes:
        raise ValueError('Incorrect xpath: No nodes')

    versions = []
    for node in nodes:
        if attribute:
            string = node.get(attribute)
        else:
            string = node.text

        if regex:
            obj = re.search(regex, string)
            if not obj:
                continue
            elif len(obj.groups()) > 1:
                raise ValueError('Incorrect regex: More than 1 capture group')
            string = obj.group(1)

        versions.append(distutils.version.LooseVersion(string))

    if not versions:
        raise ValueError('Incorrect regex: No match')

    versions = sorted(versions, reverse=True)

    return versions[0]

def pacman(package):
    ''' Return dict with repository versions of package '''
    try:
        output = subprocess.check_output(
            [
                '/usr/bin/expac', '--sync', '--search',
                '%r %v', r'^' + package + r'$'
            ]
        ).decode('UTF-8').splitlines()
    except subprocess.CalledProcessError:
        raise RuntimeError('{:1s} not in any repository'.format(package))

    versions = {}
    for line in output:
        repo, version = line.split()
        versions[repo] = distutils.version.LooseVersion(version)

    return versions

def dockerfile_update(path, variable, version):
    ''' Update Dockerfiles with current version '''
    with open(path, 'r') as filed:
        newfile, found = re.subn(
            variable + r'=".+"',
            '{:1s}="{:2s}"'.format(variable, version),
            filed.read(),
        )

    if not found:
        raise ValueError('Did not find ENV variable')
    elif found > 1:
        raise ValueError('More than 1: {:1s}'.format(variable))

    with open(path, 'w') as filed:
        filed.write(newfile)

def main():
    ''' Main '''
    subprocess.check_call(['/usr/bin/sudo', '/usr/bin/pacman', '--sync', '--refresh'])

    print_spacer()

    for image, image_dict in IMAGES.items():
        print('\n{0:s}'.format(image))
        if 'disabled' in image_dict and image_dict['disabled']:
            print('Disabled')
            continue

        if 'packages' in image_dict:
            for package, package_dict in image_dict['packages'].items():
                print('\033[32m{:s}\033[0m:'.format(package))

                for source, source_dict in package_dict['sources'].items():
                    source_dict['version'] = scrape(
                        source_dict['url'],
                        source_dict['xpath'],
                        source_dict['attribute'] if 'attribute' in source_dict else None,
                        source_dict['regex'] if 'regex' in source_dict else None,
                    )

                try:
                    for repo, version in pacman(package).items():
                        package_dict['sources'][repo] = {'version': version}
                except RuntimeError as error:
                    print(error)

                for source, source_dict in package_dict['sources'].items():
                    print_version(source, source_dict['version'].vstring)

                dockerfile_update(
                    os.path.join(IMAGEDIR, image.replace(':', '/'), 'Dockerfile'),
                    package_dict['variable'],
                    package_dict['sources'][package_dict['download']]['version'].vstring,
                )

    print_spacer()

if __name__ == '__main__':
    main()
