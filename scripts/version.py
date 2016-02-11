#!/usr/bin/python3
''' Check image package versions '''

import distutils.version
import re
import subprocess

import lxml.html
import requests
from termcolor import cprint

from utils.image import IMAGES, META, path_dockerfile


def fetch(url, headers, timeout):
    ''' Fetch URL '''
    try:
        response = requests.get(url, headers=headers, timeout=timeout)
        response.raise_for_status()
    except (requests.exceptions.Timeout, requests.exceptions.HTTPError) as error:
        raise RuntimeError('fetch: {0:s}\n{1:s}'.format(str(error), str(error.response.content)))
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
    document = fetch(url, META['Headers'],
                     (META['Limits']['TimeoutConnect'], META['Limits']['TimeoutRead']))
    return document_parse(document, xpath, attribute, regex)


def version_pacman(package):
    ''' Return dict with repository versions of package '''
    try:
        output = subprocess.run([
            '/usr/bin/expac', '--sync', '--search',
            '%n %r %v',
            r'^{0:s}$'.format(re.escape(package)),
        ], check=True, stdout=subprocess.PIPE).stdout.decode('UTF-8')
    except subprocess.CalledProcessError:
        raise RuntimeError('{0:s} not in any repository'.format(package))

    versions = {}
    for line in output.splitlines():
        name, repo, version = line.split()
        if name == package:
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

    for image, image_dict in IMAGES.items():
        cprint('\n{0:s}'.format(image), 'white', attrs=['underline'])
        if 'Check' in image_dict and not image_dict['Check']:
            print('Not checked!')
            continue

        if 'Packages' in image_dict:
            for package, package_dict in image_dict['Packages'].items():
                cprint('{0:s}:'.format(package), 'yellow')

                for source, source_dict in package_dict['Sources'].items():
                    source_dict['Version'] = version_scrape(
                        source_dict['URL'],
                        source_dict['XPath'],
                        source_dict['Attribute'] if 'Attribute' in source_dict else None,
                        source_dict['Regex'] if 'Regex' in source_dict else None,
                    )

                try:
                    for repo, version in version_pacman(package).items():
                        package_dict['Sources'][repo] = {'Version': version}
                except RuntimeError as error:
                    cprint(str(error), 'red')

                for source, source_dict in package_dict['Sources'].items():
                    print('{0:15s}{1:s}'.format(source, source_dict['Version'].vstring))

                dockerfile_update(
                    path_dockerfile(image),
                    package_dict['Variable'],
                    package_dict['Sources'][package_dict['Download']]['Version'].vstring,
                )

if __name__ == '__main__':
    main()
