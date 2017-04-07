# =============================================================================
# SaltStack Beacon
#
# NAME: _beacons/rabbitmq_queue_checker.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 0.1
# DATE  : 2016.07.11
#
# PURPOSE: Send back number of messages from all RabbitMQ queues.
#
# CHANGE LOG:
#
# NOTES:
#

from __future__ import absolute_import
import logging
from socket import getfqdn
from sys import exit, exc_info

log = logging.getLogger(__name__)
__virtualname__ = 'rabbitmq_queue_checker'

try:
    import pyrabbit
except Exception as err:
    log.warn('{0}'.format(err[0]))
    exit(1)


def __virtual__():
    return __virtualname__


def validate(config):
    '''
    Validate the beacon configuration
    '''
    if not isinstance(config, dict):
        log.info('Config for rabbitmq_queue_checker beacon must be a dict.')
        return False
    for x in ['socket', 'user', 'pass', 'vhost', 'tag_append']:
        if x not in keys(config):
            log.debug('Could not find {0} in config.'.format(x))
            return False
    return True


def get_rabbitmq_stats(rabbit_socket, vhost, rabbit_user, rabbit_pass):
    '''Get RabbitMQ stats for all queues of a particular vhost'''
    pyrabbit_client = pyrabbit.api.Client(rabbit_socket, rabbit_user, rabbit_pass)

    try:
        queues = pyrabbit_client.get_queues(vhost)
    except pyrabbit.http.NetworkError as err:
        log.debug("pyrabbit.http.NetworkError: {0}".format(err))
        return False
    except TypeError as err:
        log.debug("TypeError: {0}".format(err))
        return False
    except Exception as err:
        log.debug('{0}'.format(err[0]))
        return False

    total_messages = 0
    for queue in queues:
        try:
            total_messages += int(queue['messages'])
        except Exception as err:
            log.debug('{0}'.format(err[0]))
    queues_stats = [{'name': 'Total from all queues', 'messages': str(total_messages)}]
    return queues_stats


def beacon(config):
    '''
    Send back number of messages from all RabbitMQ queues.

    Specify which vhosts to check.

    .. code-block:: yaml

        beacons:
          rabbitmq_queue_checker:
            enabled: True
            interval: 300
            socket: 'localhost:15672'
            user: some_user
            pass: some_pass
            vhost: 'some_vhost'
            tag_append: ''
    '''

    log.debug('socket: {0}, vhost: {1}'.format(config['socket'], config['vhost']))
    rabbitmq_stats = get_rabbitmq_stats(config['socket'], config['vhost'], config['user'], config['pass'])
    log.debug("Stats: {0}".format(rabbitmq_stats))

    ret = []
    ret.append({__virtualname__: rabbitmq_stats, 'tag': config['tag_append']})
    return ret
