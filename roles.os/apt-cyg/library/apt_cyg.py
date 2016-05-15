#!/usr/bin/python
# -*- coding: utf-8 -*-
# $ANSIBLE_HOME/hacking/test-module -m ./library/apt-cyg -a "version=0.1.0 prefix=$HOME/bin"
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

from ansible.module_utils.basic import *

def main():

    states = [
        'anything',
        'latest',
    ]

    module = AnsibleModule(
        argument_spec=dict(
            name=dict(default=None, required=True),
            state=dict(default='latest', choices=states),
        ),
        supports_check_mode=True,
    )

    name = module.params['name']
    state = module.params['state']
    check_mode = module.check_mode

    try:
        apt_cyg_path = module.get_bin_path('apt-cyg', required=True)

        current_version = installed_version(module, apt_cyg_path, name)
        latest = latest_version(module, apt_cyg_path, name)

        if state == 'anything' and current_version != None:
            module.exit_json(changed=False)
            return

        if current_version == None or latest != current_version:
            if check_mode:
                module.exit_json(changed=True)
                return
        else:
            module.exit_json(changed=False)
            return

        module.run_command('%s remove %s' % (apt_cyg_path, name), check_rc=True)
        module.run_command('%s install %s' % (apt_cyg_path, name), check_rc=True)
        module.exit_json(changed=True, msg='%s %s' % (current_version, latest))

    except Exception as e:
        module.fail_json(msg=str(e))

def installed_version(module, apt_cyg_path, name):
    (rc, out, err) = module.run_command("awk '$1~pkg && $0=$2' pkg=^%s$ /etc/setup/installed.db" % (name))
    r = re.compile(r"%s-([0-9a-zA-Z]+\.[0-9a-zA-Z]+\.[0-9a-zA-Z]+-[0-9a-zA-Z]+)" % (name))
    version = r.search(out)
    installed_version = None
    if version != None:
        installed_version = version.group(1)

    return installed_version

def latest_version(module, apt_cyg_path, name):
    (rc, out, err) = module.run_command('%s show %s' % (apt_cyg_path, name))
    r = re.compile(r"version: ([0-9\.-]+)")
    version = r.search(out.strip())
    latest_version = None
    if version != None:
        latest_version = version.group(1)

    return latest_version

main()
