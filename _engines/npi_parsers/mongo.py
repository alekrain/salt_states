import json
import logging
log = logging.getLogger(__name__)


def mongo_replset_status(epoch_time, svc_name, data, thresholds, nagios_cmd_file):
    '''
    Parser to ingest data from the mongo_replset_status beacon.

    Example:
    tag: salt/beacon/mongo1.smartaleksolutions.com/mongo_replset_status/
    data: {'_stamp': '2016-11-18T14:27:22.867468',
            'data': {
                'mongo_replset_status': {
                    "term":162,
                    "set":"databank_repl_set0",
                    "ok":1.0,
                    "heartbeatIntervalMillis":2000,
                    "myState":1,
                    "members":[
                        {
                            "uptime":7296,
                            "configVersion":3,
                            "optime":{
                                "ts":{
                                    "$timestamp":{
                                        "t":1479471978,
                                        "i":1
                                    }
                                },
                                "t":162
                            },
                            "name":"minion1.smartaleksolutions.com:27017",
                            "pingMs":0,
                            "optimeDate":{
                                "$date":1479471978000
                            },
                            "syncingTo":"minion2.smartaleksolutions.com:27017",
                            "state":2,
                            "health":1.0,
                            "stateStr":"SECONDARY",
                            "lastHeartbeatRecv":{
                                "$date":1479479273622
                            },
                            "_id":0,
                            "lastHeartbeat":{
                                "$date":1479479272842
                            }
                        },
                        {
                            "uptime":174803,
                            "configVersion":3,
                            "optime":{
                                "ts":{
                                    "$timestamp":{
                                        "t":1479471978,
                                        "i":1
                                    }
                                },
                                "t":162
                            },
                            "name":"minion2.smartaleksolutions.com:27017",
                            "self":true,
                            "optimeDate":{
                                "$date":1479471978000
                            },
                            "electionTime":{
                                "$timestamp":{
                                    "t":1479471977,
                                    "i":1
                                }
                            },
                            "state":1,
                            "health":1.0,
                            "stateStr":"PRIMARY",
                            "_id":1,
                            "electionDate":{
                                "$date":1479471977000
                            }
                        },
                        {
                            "uptime":13556,
                            "configVersion":3,
                            "name":"minion3.smartaleksolutions.com:27017",
                            "pingMs":0,
                            "state":7,
                            "health":1.0,
                            "stateStr":"ARBITER",
                            "lastHeartbeatRecv":{
                                "$date":1479479269597
                            },
                            "_id":2,
                            "lastHeartbeat":{
                                "$date":1479479272684
                            }
                        }
                    ],
                    "date":{
                        "$date":1479479273627
                    }
                }
            'id': 'databank.smartaleksolutions.com'
            }
        }
    '''
    data[svc_name] = json.loads(data[svc_name])
    host_name = data['id']
    return_string = ''
    return_code = 0
    perf_data = ''
    primary_optime = 0
    secondary_optime = 0

    if data[svc_name]['error']:
        log.debug('{0}'.format(data[svc_name]['error']))
        return_string = '{0}'.format(data[svc_name]['error'])
        return_code = 2
    else:
        for member in data[svc_name]['members']:
            log.debug('Iterating through replset members')
            log.debug('MEMBER: {0}'.format(member))
            name = member['name']
            health = member['health']
            state = member['state']
            state_string = member['stateStr']

            log.debug("Checking status of replset member {0}".format(name))
            log.debug("{0} is currently {1}".format(name, state_string))

            if state_string == 'PRIMARY':
                primary_optime = member['optime']['ts']['$timestamp']['t']
                log.debug('Primary optime: {0}'.format(primary_optime))
            elif state_string == 'SECONDARY':
                secondary_optime = member['optime']['ts']['$timestamp']['t']
                log.debug('Secondary optime: {0}'.format(secondary_optime))

            if health == 0:
                log.debug("{0} is DOWN!".format(name))
                return_string = '{0} is DOWN! '.format(name)
                return_code = 2
            else:
                return_string += '{0} is {1}. '.format(name, state_string)
                if (state == 1 or state == 2 or state == 7) and return_code == 0:
                    pass
                elif state == 5 and return_code == 0:
                    return_code = 1
                else:
                    return_code = 2

    perf_data = 'Time_Between_Replication={0}'.format(secondary_optime - primary_optime)
    return epoch_time, host_name, svc_name, return_code, plugin_output, perf_data
