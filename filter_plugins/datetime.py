import datetime

class FilterModule(object):
    def filters(self):
        return {
            'timestamp': format_timestamp
        }

def format_timestamp(value, format='datetime'):
    if format == 'datetime':
        format = '%Y-%m-%d %H:%M:%S'
    elif format == 'date':
        format = '%Y-%m-%d'
    elif format == 'time':
        format = '%H:%M:%S'
    return datetime.datetime.fromtimestamp(value).strftime(format)
