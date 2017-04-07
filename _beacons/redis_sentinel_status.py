# =============================================================================
# SaltStack Beacon
#
# NAME: _beacons/redis_sentinel_status
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 1.0
# DATE : 2016.11.28
#
# PURPOSE: Checks the status of redis replication sets and returns status.
#

import logging

log = logging.getLogger(__name__)
__virtualname__ = 'redis_sentinel_status'

try:
    import redis
except Exception as err:
    log.warn('{0}'.format(err[0]))
    exit(1)


def __virtual__():
    return __virtualname__


def validate(config):
    '''
    Validate the beacon configuration
    '''
    # Configuration for network_sockets_open beacon should be a list of lists
    if not isinstance(config, dict):
        log.info('Configuration for this beacon must be a dict.')
        return False
    for x in ['host', 'redis_port', 'sentinel_port', 'replset', 'tag_append']:
        if x not in keys(config):
            log.debug('Could not find {0} in config.'.format(x))
            return False
    return True


def _query_redis(config):
    '''Query Redis for various values to determine status of replication set'''
    host = config['host']
    port = config['port']
    replset = config['replset']
    results = {}

    Sentinel = redis.Redis(host=host, port=port, db=0, socket_timeout=5)
    results['master'] = Sentinel.sentinel_master(replset)
    results['slaves'] = Sentinel.sentinel_slaves(replset)
    results['sentinels'] = Sentinel.sentinel_sentinels(replset)

    return results


def beacon(config):
    '''
    Send back select fields from both redis info and sentinel commands.

    2016.02.15 - tag_append param is new. By default beacons return with a tag
    of salt/beacons/< minion_id >/__virtualname__/. This param gives the option
    to append something to the end of that tag.

    .. code-block:: yaml

        beacons:
          redis_sentinel_status:
            enabled: True
            interval: 60
            host: 192.168.1.1
            port: 26379
            replset: redis_repl1
            tag_append: ''
    '''

    repl_status = _query_redis(config)
    log.debug("Redis replset status: {0}".format(repl_status))

    ret = []
    ret.append({__virtualname__: repl_status, 'tag': tag_append})
    return ret
