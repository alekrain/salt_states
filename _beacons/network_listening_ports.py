# =============================================================================
# SaltStack Beacon
#
# NAME: _beacons/network_listening_ports.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 1.0
# DATE : 2016.11.17
#
# PURPOSE: Returns a list of all listening ports. Ports may be exclued from the
#   return by being added to the 'omit' list in pillar.
#
# NOTES:


'''
Beacon to monitor number of open network sockets.
'''

# Import Python libs
from __future__ import absolute_import
import logging
import re
from sys import exit

log = logging.getLogger(__name__)
__virtualname__ = 'network_listening_ports'

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
        log.info('Configuration for network_listening_ports beacon must be a dict.')
        return False
    return True


def beacon(config):
    '''
    Monitor the number of sockets open on the minion

    Specify which listening ports do not need to be reported back.

    .. code-block:: yaml

        beacons:
          network_listening_ports:
            omit:
              - 445
    '''
    for omit in config['omit']:
        log.debug('Omit port: {0}'.format(omit))

    try:
        conns = psutil.net_connections(kind='tcp4')
    except Exception as err:
        log.error('{0}'.format(err[0]))
        exit(1)

    ret = []
    ports = []
    for conn in conns:
        match = re.search('0\.0\.0\.0\',\s([0-9]{1,5})', str(conn))
        if match:
            port = int(match.group(1))
            if port not in config['omit']:
                log.debug('Adding Port {0}'.format(port))
                ports.append(port)
    ret.append({__virtualname__: ports})
    return ret
