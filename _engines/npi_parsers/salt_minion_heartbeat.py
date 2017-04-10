import logging
log = logging.getLogger(__name__)


def salt_minion_heartbeat(epoch_time, svc_name, data, thresholds, nagios_cmd_file):
    '''
    Parser to ingest data received from the salt_minion_heartbeat beacon.
    Incoming salt events look like:
        data = {'salt_minion_heartbeat': 1472683942, 'id': 'kraken.somedomain.com'}
    '''
    return_code = 0
    plugin_output = ''
    host_name = data['id']

    data_epoch_time = int(data[svc_name])
    log.debug('Set data_epoch_time to {0}'.format(data_epoch_time))

    diff_time = abs(epoch_time - data_epoch_time)
    log.debug('Diff time: {0}'.format(diff_time))

    perf_data = '{0}={1};{2};{3}'.format(svc_name, diff_time, thresholds['warning'], thresholds['critical'])
    log.debug('Thresholds: {0} {1} {2}'.format(thresholds['ok'], thresholds['warning'], thresholds['critical']))

    if diff_time >= int(thresholds['critical']):
        plugin_output += "CRITICAL: System time off by more than {0} seconds.\t".format(thresholds['critical'])
        return_code = 2
    elif diff_time >= int(thresholds['warning']):
        plugin_output += "WARNING: System time off by more than {0} seconds.\t".format(thresholds['warning'])
        return_code = 1
    elif diff_time >= int(thresholds['ok']):
        plugin_output += "OK: last minion heartbeat: {0}".format(epoch_time)
    else:
        log.debug("DATA TIME: {0}, NAGIOS TIME: {1}, DIFF={2}".format(data_epoch_time, epoch_time, diff_time))
        plugin_output += "ERROR: Value is either less than 0 or NAN (Check your timezones)."
        return_code = 3

    return epoch_time, host_name, svc_name, return_code, plugin_output, perf_data
