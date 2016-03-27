import json

class FilterModule(object):
  def filters(self):
    return {'stat_log': stat_log}

def stat_log(a):
  # r = '%s - %s' % (a['key'], a['value']['svn_tag'])
  # return r
  o = {item: a.item, stat: a.stat}
  return o

# import operator
# def sort_multi(L,*operators):
#   L.sort(key=operator.itemgetter(*operators))
