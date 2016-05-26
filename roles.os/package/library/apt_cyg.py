#!/usr/bin/python
# -*- coding: utf-8 -*-
# $ANSIBLE_HOME/hacking/test-module -m ./library/apt-cyg -a "version=0.1.0 prefix=$HOME/bin"

# https://github.com/naokirin/ansible-apt-cyg-module/blob/master/library/apt-cyg
DOCUMENTATION = '''
---
module: apt-cyg
short_description: run apt-cyg
description:
  - run apt-cyg
options:
  name:
    description:
      - apt-cyg package name
    required: true
    default: null
  state:
    description:
      - choiced package version state
    required: false
    choices: [ "latest", "anything" ]
    default: latest
author: naokirin
'''

EXAMPLES='''
- apt-cyg: name=ruby state="latest"
  description: install latest apt-cyg ruby package
'''

import sys
import tempfile
import zipfile
import shutil
import re

# if isinstance(name, list):
#     names = ' '.join(name)

# try:
#     current_version = installed_version(module, name)
#     latest = latest_version(module, name)
#     if p['state'] == 'anything' and current_version != None:
#         module.exit_json(changed=False)
#         return
#     if current_version == None or latest != current_version:
#         if module.check_mode:
#             module.exit_json(changed=True)
#             return
#     else:
#         module.exit_json(changed=False)
#         return
#     module.exit_json(changed=True, msg='%s %s' % (current_version, latest))
#     module.exit_json(changed=True, msg='%s %s' % (current_version, latest))
# except Exception as e:
#     module.fail_json(msg=str(e))

def install_packages(module):
    if not module.check_mode:
        cmd = '%s update' % (APT_CYG_PATH)

    rc, stdout, stderr = module.run_command(cmd, check_rc=False)
    if rc != 0:
        module.fail_json(msg='failed to update package list')
    # Always outputs: 'Updated setup.ini'
    if not re.search('^Updated', stdout):
        module.exit_json(changed=False, msg='package list already updated')
    module.exit_json(changed=True, msg='updated package list')

def install_packages(module, names, state):
    absent = []
    outdated = []
    for name in names:
        current_version = installed_version(module, name)
        latest = latest_version(module, name)
        if not current_version: # == None
            absent.append(name)
        elif state == 'latest' and latest != current_version:
            outdated.append(name)
    if not absent and not outdated:
        module.exit_json(changed=False, msg='package(s) already installed')
    names = ' '.join(absent + outdated)

    if not module.check_mode:
        cmd = '%s install %s' % (APT_CYG_PATH, names)

    rc, stdout, stderr = module.run_command(cmd, check_rc=False)
    if rc != 0:
        module.fail_json(msg='failed to install %s' % (names))
    module.exit_json(changed=True, msg='installed %s package(s)' % (names))

def remove_packages(module, names):
    present = []
    for name in names:
        current_version = installed_version(module, name)
        if current_version: # != None
            present.append(name)
    if not present:
        module.exit_json(changed=False, msg='package(s) already removed')
    names = ' '.join(present)

    if not module.check_mode:
        cmd = '%s remove %s' % (APT_CYG_PATH, names)

    rc, stdout, stderr = module.run_command(cmd, check_rc=False)
    if rc != 0:
        module.fail_json(msg='failed to remove %s package(s)' % (names))
    module.exit_json(changed=True, msg='removed %s package(s)' % (names))

def installed_version(module, name):
    (rc, out, err) = module.run_command('awk "$1~pkg && $0=$2" pkg=^%s$ /etc/setup/installed.db' % (name))
    r = re.compile(r'%s-([0-9a-zA-Z]+\.[0-9a-zA-Z]+\.[0-9a-zA-Z]+-[0-9a-zA-Z]+)' % (name))
    version = r.search(out)
    installed_version = None
    if version != None:
        installed_version = version.group(1)

    return installed_version

def latest_version(module, name):
    (rc, out, err) = module.run_command('%s show %s' % (APT_CYG_PATH, name))
    r = re.compile(r'version: ([0-9\.-]+)')
    version = r.search(out.strip())
    latest_version = None
    if version != None:
        latest_version = version.group(1)

    return latest_version

# ==========================================

def main():
    module = AnsibleModule(
        argument_spec = dict(
            state = dict(default='latest', choices=['present', 'absent', 'latest', 'anything']),
            name = dict(type='list'),
            update = dict(default='no', type='bool'),
        ),
        required_one_of = [['name', 'update']],
        # supports_check_mode = True,
    )

    global APT_CYG_PATH
    APT_CYG_PATH = module.get_bin_path('apt-cyg', required=True)

    p = module.params

    if p['update']:
        update_packages(module)

    # FIXME
    # install make, git, tmux: always changed?
    # remove make: not possible?
    if p['state'] in ['present', 'latest']:
        install_packages(module, p['name'], p['state'])
    elif p['state'] == 'absent':
        remove_packages(module, p['name'])
    else:
        module.fail_json(msg='unknown state %s' % (p['state']))

# Import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
