import logging
log = logging.getLogger(__name__)


def rabbitmq_queue_checker(epoch_time, svc_name, data, thresholds, nagios_cmd_file):
    '''
    Parser to ingest data received from the salt rabbitmq beacon.

    Example:
    tag: salt/beacon/rabbit1.smartaleksolutions.com/rabbitmq_queue_checker/
    data: {'rabbitmq_queue_checker': [{'messages': '47', 'name': 'Total from all queues'}]
    '''
    log.debug('DATA RECEIVED:{0}'.format(data))
    host_name = data['id']

    return_code = 0
    plugin_output = ''
    perf_data = ''

    if isinstance(data[svc_name], list):
        for item in data[svc_name]:
            try:
                name = str(item['name'])
                messages = int(item['messages'])
            except:
                log.debug("Name or Message number not found! Data not formatted correctly: {0}".format(exc_info()[0]))
                return False

            perf_data += '{0}={1};{2};{3} '.format(name, messages, thresholds['warning'], thresholds['critical'])
            if messages > thresholds['critical']:
                plugin_output += 'CRITICAL: {0}: {1} messages!\t'.format(
                    name, messages)
                return_code = 2
            elif messages > thresholds['warning']:
                plugin_output += 'WARNING: {0}: {1} messages!\t'.format(
                    name, messages)
                return_code = 1
            elif messages <= thresholds['ok']:
                plugin_output += 'OK: {0}: {1} messages.\t'.format(
                    name, messages)
            else:
                plugin_output += 'UNKNOWN: {0}: {1} messages.\t'.format(
                    name, messages)
                return_code = 3
    else:
        plugin_output = 'Data Sent: {0}'.format(data[svc_name])
        return_code = 3

    return epoch_time, host_name, svc_name, return_code, plugin_output, perf_data
