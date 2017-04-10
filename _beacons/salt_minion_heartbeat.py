# =============================================================================
# SaltStack Beacon
#
# NAME: _beacons/salt_minion_heartbeat.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 0.1
# DATE  : 2016.08.09
#
# PURPOSE: Send back UTC epoch time.
#
# CHANGE LOG:
#
# NOTES:
#

from __future__ import absolute_import
import logging
from sys import exit, exc_info
from datetime import datetime
from calendar import timegm

log = logging.getLogger(__name__)
__virtualname__ = 'salt_minion_heartbeat'


def __virtual__():
    return __virtualname__


def validate(config):
    '''
    Validate the beacon configuration
    '''
    if not isinstance(config, dict):
        log.info('Config for this beacon must be a dict.')
        return False
    for x in ['tag_append']:
        if x not in keys(config):
            log.debug('Could not find {0} in config.'.format(x))
            return False
    return True


def get_minion_heartbeat():
    '''
    Get the time and display it in UTC seconds since epoch.
    '''
    d = datetime.utcnow()
    return int(timegm(d.timetuple()))


def beacon(config):
    '''
    Send back UTC epoch time.

    .. code-block:: yaml

        beacons:
          salt_minion_heartbeat:
            enabled: True
            interval: 60
            tag_append: ''
    '''

    minion_heartbeat = get_minion_heartbeat()
    log.debug('{0}: {1}'.format(__virtualname__, minion_heartbeat))
    ret = []
    ret.append({__virtualname__: minion_heartbeat, 'tag': config['tag_append']})
    return ret
