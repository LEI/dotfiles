import json

class FilterModule(object):
    def filters(self):
        return {
          'stat': stat_log
        }

def stat_log(data):
    for item in data:
        item = item
    return data
    # r = '%s - %s' % (a['key'], a['value']['svn_tag'])
    # return r

# # import operator
# # def sort_multi(L,*operators):
# #   L.sort(key=operator.itemgetter(*operators))
