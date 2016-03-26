import json

class FilterModule(object):
  def filters(self):
    return {'stat_filter': stat_filter}

def stat_filter(a):
  # r = '%s - %s' % (a['key'], a['value']['svn_tag'])
  # return r
  o = { item: a['item'], stat: a['stat'] }
  return a
