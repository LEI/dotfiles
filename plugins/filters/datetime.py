import datetime

class FilterModule(object):
    def filters(self):
        return {
            'datetime': format_datetime
        }

def format_datetime(value, format='default'):
    if format == 'default':
        format = '%Y-%m-%d@%H:%M:%S'
    elif format == 'date':
        format = '%Y-%m-%d'
    return datetime.datetime.fromtimestamp(value).strftime(format)
