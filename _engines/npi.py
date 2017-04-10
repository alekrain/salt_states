# =============================================================================
# SaltStack Engine File
#
# NAME: _engines/npi.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.07.11
#
# PURPOSE: Ingest events on the salt bus and make them passive nagios alerts.
#
# NOTES:
#

from __future__ import absolute_import
import logging
import salt.utils
import salt.config
import calendar
import time
from npi_parsers.salt_minion_heartbeat import salt_minion_heartbeat
from npi_parsers.rabbitmq import rabbitmq_queue_checker
from npi_parsers.mongo import mongo_replset_status
from npi_parsers.redis import redis_repl_status, redis_sentinel_status
import npi


log = logging.getLogger(__name__)


def convert_to_epoch_time(salt_event_time):
    '''
    Convert Salt Event Times into Epoch times for acceptance into Nagios.
    Nagios will interpret this time to be UTC and not localize it.
    '''
    date_time = salt_event_time.split('.')[0]
    pattern = '%Y-%m-%dT%H:%M:%S'
    epoch_time = int(calendar.timegm(time.strptime(date_time, pattern)))
    return epoch_time


def send_to_nagios(nagios_cmd_file, results):
    '''
    When you are done processing, the final result must be in the format of:
    [<timestamp>] PROCESS_SERVICE_CHECK_RESULT;<host_name>;<svc_description>;<return_code>;<plugin_output>
    '''

    log.debug('SEND TO NAGIOS: {0}'.format(results))
    try:
        with open(nagios_cmd_file, 'w') as FH:
            FH.write(results)
    except IOError as err:
        log.error('Could not write to Nagios command file: {0}'.format(err))


def start(nagios_cmd_file, thresholds):
    '''
    The arguments that are passed to this function come from the sls that contains the top level key "engines:"
    '''

    if __opts__.get('id').endswith('_master'):
        event_bus = salt.utils.event.get_master_event(
            __opts__,
            __opts__['sock_dir'],
            listen=True)
    else:
        event_bus = salt.utils.event.get_event(
            'minion',
            transport=__opts__['transport'],
            opts=__opts__,
            sock_dir=__opts__['sock_dir'],
            listen=True)
    log.debug('Nagios Passive Ingest (npi) engine started.')

    # Dictionary that contains all of the parsers. The first key in the "data"
    # is what informs us of the parser to run the data against.
    parsers = {
               'salt_minion_heartbeat': salt_minion_heartbeat,
               'mongo_replset_status': mongo_replset_status,
               'rabbitmq_queue_checker': rabbitmq_queue_checker,
               'redis_repl_status': redis_repl_status,
               'redis_sentinel_status': redis_sentinel_status}

    while True:
        event = event_bus.get_event()
        if event:
            log.debug('Checking to see which parser to invoke')
            if 'data' in event:
                if isinstance(event['data'], dict):
                    event_keys = event['data'].keys()
                    for key in event_keys:
                        if key in parsers:
                            epoch_time = convert_to_epoch_time(event['_stamp'])
                            log.debug('{0}: Converted {0} to {1}'.format(event['_stamp'], epoch_time))
                            log.debug('Calling Parser {0}'.format(key))
                            epoch_time, host_name, svc_name, return_code, plugin_output, perf_data = parsers[key](
                                epoch_time, key, event['data'], thresholds[key], nagios_cmd_file)
                            send_to_nagios(
                                nagios_cmd_file, u'[{0}]\tPROCESS_SERVICE_CHECK_RESULT;{1};{2};{3};{4}|{5}\t\n'.format(
                                    epoch_time, host_name, svc_name, return_code, plugin_output, perf_data))
                        else:
                            log.debug('Key {0}, could not be found in the parsers'.format(key))
                else:
                    log.debug('Data in the event is not dict. Skipping...')
            else:
                log.debug('No data in the event.')
