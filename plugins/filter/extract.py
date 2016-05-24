# https://github.com/ansible/ansible/issues/15279
# TODO check if already defined (>2.0)
def extract(item, container, morekeys=None):
    value = container[item]

    # value is not Undefined
    if morekeys is not None:
        if not isinstance(morekeys, list):
            morekeys = [morekeys]

        value = reduce(lambda d, k: d[k], morekeys, value)

    return value

class FilterModule(object):
    ''' Ansible extract filter '''

    def filters(self):
        return {
            # array and dict lookups
            'extract': extract,
        }
