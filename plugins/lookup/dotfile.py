from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
import glob
# import sys
from stat import *

from ansible.plugins.lookup import LookupBase
from ansible.errors import AnsibleError, AnsibleFileNotFound

class LookupModule(LookupBase):

    userdir = os.path.expanduser("~")

    def run(self, terms, variables=None, **kwargs):

        self.homedir = variables['ansible_env']['HOME']
        self.basedir = self.get_basedir(variables)

        # if len(terms) >= 0:
        args = terms[0].split(',')
        if len(args) >= 1 and args[0].startswith(os.sep):
            role_path = args[0]
        else:
            role_path = self.get_role_path(args, variables)

        # exists = True
        # try:
        #     stat = os.stat(role_path)
        # except OSError, e:
        #     exists = False
        #     # if e.errno == errno.ENOENT:

        if len(role_path) > 0: # and exists == True:
            path = role_path
        # else:
        #     raise AnsibleError("Not found: role_path '%s'" % role_path)

        search = []
        if len(terms) >= 2:
            search.append(terms[1]) # [1:]
        else:
            search.append(['*'])

        params = {
            'dest': False,
            'prefix': False,
            'substr': False,
            }

        if len(terms) >= 3:
            params.update(terms[2])

        ret = []
        for pattern in search:
            term = os.path.join(path, pattern)
            # ret.extend(s for s in [term])
            term_file = os.path.basename(term)
            # dwimmed_path = self._loader.path_dwim_relative(basedir, 'files', os.path.dirname(term))
            # dwimmed_path = self.find_file_in_search_path(variables, 'files', os.path.dirname(term))
            p = os.path.join(os.path.dirname(term), term_file)
            globbed = glob.glob(p)
            # if len(globbed) == 0:
            #     raise AnsibleFileNotFound("%s" % p)

            paths = []
            for g in globbed:
                st = self.get_stat(g, variables)
                if st['exists'] == True:
                    if self.userdir != self.homedir and '/templates/' not in st['path']:
                        # Fake remote lookup
                        st['path'] = st['path'].replace(self.userdir, self.homedir)
                    basename = os.path.basename(st['path'])
                    st['dest'] = self.get_dest(basename, params)
                paths.append(st)

            ret.extend(p for p in paths if p['exists'] == True) # if os.path.isfile(g))

        return ret

    def get_dest(self, name, params):
        dest = params['dest']
        prefix = params['prefix']
        substr = params['substr']

        if dest and len(dest) > 0:
            if not dest.startswith(self.homedir):
                dest = os.path.join(self.homedir, dest)
        else:
            dest = self.homedir

        if prefix and len(prefix) > 0:
            name = prefix + name
        if substr and len(substr) > 0:
            name = name.replace(substr, '')

        return os.path.join(dest, name)

    def get_stat(self, path, variables):
        follow = False

        try:
            if follow:
                st = os.stat(path)
            else:
                st = os.lstat(path)

            d = {
                'exists': True,
                'path': path,
                # 'mode': "%04o" % S_IMODE(st.st_mode),
                # 'isdir': S_ISDIR(st.st_mode),
                # 'link': os.path.realpath(path) if S_ISLNK(st.st_mode) else False,
                }
        except OSError, e:
            d = { 'exists': False }
            # if e.errno == errno.ENOENT: # Does not exists
                # raise AnsibleFileNotFound("could not locate file in lookup: %s" % g)

        return d

    def get_role_path(self, terms, variables):

        # Inventory file must be at the root
        root = variables['inventory_dir']

        default_roles_directory = 'roles'

        roles_path, role_name = os.path.split(self.basedir)

        if len(terms) >= 1:
            role_name = terms[0]

        if len(terms) >= 2 and terms[1] is not None and len(terms[1]) > 0:
            roles_directory = terms[1]
        else:
            roles_directory = default_roles_directory

        if root != os.path.dirname(roles_path):
            roles_basename = roles_path.replace(root + '/' + roles_directory + '/', '')
            roles_path = roles_path.replace('/' + roles_basename, '')
        else:
            roles_basename = os.path.basename(roles_path)

        if roles_basename != roles_directory:
            role_path = os.path.join(os.path.dirname(roles_path), roles_directory)
        else:
            role_path = roles_path

        role_path = os.path.join(role_path, role_name)

        # Append extra arguments as directories
        if len(terms) >= 3:
            for term in terms[2:]:
                role_path = os.path.join(role_path, term)

        return role_path
