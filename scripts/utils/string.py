''' String manipulation '''

import re
import uuid

from utils.meta import META


def re_backup(string):
    ''' BackupPrefix regex '''
    return re.compile(r'^{0:s}(\d+)_{1:s}$'.format(
        re.escape(META['BackupPrefix']), re.escape(string)))


def add_uuid(string):
    ''' Add uuid to string '''
    return '{0:s}-{1:s}'.format(string, uuid.uuid4().hex)


def add_tmp(string):
    ''' Remove TmpPrefix from string '''
    return META['TmpPrefix'] + string


def rm_tmp(string):
    ''' Remove TmpPrefix from string '''
    return string[META['TmpPrefixLen']:] if string.startswith(META['TmpPrefix']) else string


def backup_num(name, string):
    ''' Extract number from backup string '''
    match = re_backup(name).search(string)
    return int(match.group(1)) if match else None


def backup_old(name, string):
    ''' Check if backup number is greater than Backups '''
    number = backup_num(name, string)
    if number is None:
        return False
    elif number <= META['Backups']:
        return False
    else:
        return True


def backup_incr(name, string):
    ''' Increment BackupPrefix number '''
    if string == name:
        return META['BackupPrefix'] + '1' + '_' + name

    number = backup_num(name, string)
    if number is None:
        return None
    else:
        return META['BackupPrefix'] + str(number + 1) + '_' + name
