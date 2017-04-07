# =============================================================================
# SaltStack Beacon
#
# NAME: _beacons/network_sockets_open.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 1.0
# DATE : 2016.11.17
#
# PURPOSE: Returns the number of sockets currently open on a host.
#
# NOTES: Mongo Status Codes


'''
Beacon to monitor number of open network sockets.
'''

# Import Python libs
from __future__ import absolute_import
import logging
import re
from sys import exit

log = logging.getLogger(__name__)
__virtualname__ = 'network_sockets_open'

try:
    import psutil
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
        log.info('Configuration for network_sockets_open beacon must be a dictionary.')
        return False
    return True


def beacon(config):
    '''
    Monitor the number of sockets open on the minion

    Specify thresholds for number of sockets and only emit a beacon if it is
    exceeded.

    .. code-block:: yaml

        beacons:
          network_sockets_open:
            sockets: 1
    '''
    try:
        num_conns = len(psutil.net_connections())
    except Exception as err:
        log.error('{0}'.format(err[0]))
        exit(1)

    ret = []
    if num_conns > config['sockets']:
        log.debug('{0}: {1}'.format(__virtualname__, num_conns))
        ret.append({__virtualname__: num_conns})
    return ret
