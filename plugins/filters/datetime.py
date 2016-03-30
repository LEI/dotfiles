import datetime

class FilterModule(object):
    def filters(self):
        return {
            'datetime': format_timestamp
        }

def format_timestamp(value, format='default'):
    if format == 'default':
        format = '%Y-%m-%d@%H:%M:%S'
    elif format == 'date':
        format = '%Y-%m-%d'
    return datetime.datetime.fromtimestamp(value).strftime(format)
