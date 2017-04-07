# ============================================================================
# SaltStack Beacon
#
# NAME: _beacons/mongo_replset_status.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 1.0
# DATE : 2016.11.17
#
# PURPOSE: Checks the status of mongo replication sets and returns status.
#
# NOTES: Mongo Status Codes
#   Health:
#       0: Down
#       1: Up
#   State:
#       0: Startup (not an active member of replset)
#       1: Primary
#       2: Secondary
#       3: Recovering
#       5: Startup2 (Initial sync with replset)
#       6: Unknown
#       7: Arbiter
#       8: Down
#       9: Rollback
#       10: Removed


import logging
import json
from bson import json_util
from sys import exit

log = logging.getLogger(__name__)
__virtualname__ = 'mongo_replset_status'

try:
    import pymongo
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
        log.info('Configuration for this beacon must be a dict.')
        return False
    for x in ['host', 'port', 'replset', 'tag_append']:
        if x not in keys(config):
            log.debug('Could not find {0} in config.'.format(x))
            return False
    return True


def query_mongo(config):
    '''
    Query MongoDB for the status of the replication set
    '''
    host = config['host']
    port = config['port']
    replset = config['replset']

    try:
        mongo_conn = pymongo.MongoClient(host, port, replicaset=replset)
        status = mongo_conn.admin.command('replSetGetStatus')
    except pymongo.MongoClient as error:
        log.debug('Could not connect to MongoDB: {0}'.format(error))
        mongo_conn.close()
        return({'error': 'Could not connect to MongoDB: {0}'.format(error)})
    except pymongo.errors.ServerSelectionTimeoutError as error:
        log.debug('Primary in replication set appears to be down! {0}'.format(error))
        mongo_conn.close()
        return({'error': 'Primary in replication set appears to be down! {0}'.format(error)})
    mongo_conn.close()
    return json.dumps(status, default=json_util.default)


def beacon(config):
    '''
    Send back the full Mongo replication set status.

    .. code-block:: yaml

        beacons:
          mongo_replset_status:
            enabled: True
            interval: 60
            host: 192.168.1.1
            port: 27017
            replset: replication_set_1
            tag_append: ''
    '''

    log.debug("Fetching Mongo replset status.")
    repl_status = query_mongo(config)
    log.debug("Status: {0}".format(repl_status))

    ret = []
    ret.append({__virtualname__: repl_status, 'tag': config['tag_append']})
    return ret
