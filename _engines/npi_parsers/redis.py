import logging
log = logging.getLogger(__name__)


def redis_repl_status(epoch_time, svc_name, data, thresholds, nagios_cmd_file):
    '''
    Parser to ingest data received from the redis_repl_status beacon.

    Example:
    tag: salt/beacon/redis1.smartaleksolutions.com/redis_repl_status/
    data: {
            '_stamp': '2016-11-29T02:14:06.477635',
            'data': {
                'id': 'databank.smartaleksolutions.com',
                'redis_repl_status': {
                    'aof_current_rewrite_time_sec': -1,
                    'aof_enabled': 0,
                    'aof_last_bgrewrite_status': 'ok',
                    'aof_last_rewrite_time_sec': -1,
                    'aof_last_write_status': 'ok',
                    'aof_rewrite_in_progress': 0,
                    'aof_rewrite_scheduled': 0,
                    'arch_bits': 64,
                    'blocked_clients': 0,
                    'client_biggest_input_buf': 0,
                    'client_longest_output_list': 0,
                    'config_file': '/etc/redis.conf',
                    'connected_clients': 7,
                    'connected_slaves': 1,
                    'db0': {
                        'avg_ttl': 0,
                        'expires': 0,
                        'keys': 2
                    },
                    'evicted_keys': 0,
                    'expired_keys': 0,
                    'gcc_version': '4.8.3',
                    'hz': 10,
                    'instantaneous_input_kbps': 0.34,
                    'instantaneous_ops_per_sec': 6,
                    'instantaneous_output_kbps': 2.3,
                    'keyspace_hits': 0,
                    'keyspace_misses': 0,
                    'latest_fork_usec': 177,
                    'loading': 0,
                    'lru_clock': 3990638,
                    'master_repl_offset': 6184380,
                    'mem_allocator': 'jemalloc-3.6.0',
                    'mem_fragmentation_ratio': 1.82,
                    'min_slaves_good_slaves': 1,
                    'multiplexing_api': 'epoll',
                    'os': 'Linux 3.10.0-327.4.4.el7.x86_64 x86_64',
                    'process_id': 1652,
                    'pubsub_channels': 1,
                    'pubsub_patterns': 0,
                    'rdb_bgsave_in_progress': 0,
                    'rdb_changes_since_last_save': 0,
                    'rdb_current_bgsave_time_sec': -1,
                    'rdb_last_bgsave_status': 'ok',
                    'rdb_last_bgsave_time_sec': 0,
                    'rdb_last_save_time': 1480266011,
                    'redis_build_id': 'c0359e7aa3798aa2',
                    'redis_git_dirty': 0,
                    'redis_git_sha1': 0,
                    'redis_mode': 'standalone',
                    'redis_version': '2.8.19',
                    'rejected_connections': 0,
                    'repl_backlog_active': 1,
                    'repl_backlog_first_byte_offset': 5135805,
                    'repl_backlog_histlen': 1048576,
                    'repl_backlog_size': 1048576,
                    'role': 'master',
                    'run_id': 'bb189d2dea98c39ee91369aeeaf453fa93026cb0',
                    'slave0': {
                        'ip': '172.16.35.229',
                        'lag': 1,
                        'offset': 6184236,
                        'port': 6379,
                        'state': 'online'
                    },
                    'sync_full': 1,
                    'sync_partial_err': 1,
                    'sync_partial_ok': 92,
                    'tcp_port': 6379,
                    'total_commands_processed': 172296,
                    'total_connections_received': 176,
                    'total_net_input_bytes': 8791360,
                    'total_net_output_bytes': 49113477,
                    'uptime_in_days': 1,
                    'uptime_in_seconds': 119635,
                    'used_cpu_sys': 52.31,
                    'used_cpu_sys_children': 0.0,
                    'used_cpu_user': 18.84,
                    'used_cpu_user_children': 0.0,
                    'used_memory': 2005736,
                    'used_memory_human': '1.91M',
                    'used_memory_lua': 35840,
                    'used_memory_peak': 2276504,
                    'used_memory_peak_human': '2.17M',
                    'used_memory_rss': 3649536
                    }
                }
            }
    '''
    host_name = data['id']
    data = data[svc_name]
    return_string = ''
    return_code = 0
    perf_data = ''

    if data['role'] == 'master':
        return_string += 'Master is running with {0} slave(s).\n'.format(str(data['connected_slaves']))
        for x in range(0, data['connected_slaves']):
            slave = 'slave{0}'.format(str(x))
            if data[slave]['state'] == 'online':
                return_string += '{0} slave is online.'.format(data[slave]['ip'])
                return_code = 0
            elif data[slave]['state'] == 'offline':
                return_string += '{0} slave is offline!'.format(data[slave]['ip'])
                return_code = 2
            else:
                return_string += '{0} slave status is unknown!'.format(data[slave]['ip'])
                return_code = 3
        perf_data += 'repl_backlog_size={0}'.format(str(data['repl_backlog_size']))
    elif data['role'] == 'slave':
        return_string += 'Slave is running '
        if data['master_link_status'] == 'up':
            if data['master_last_io_seconds_ago'] < thresholds['ok']:
                return_string += 'and link to master is up with IO occuring {0} seconds ago.'.format(
                    str(data['master_last_io_seconds_ago']))
                return_code = 0
            elif data['master_last_io_seconds_ago'] < thresholds['warning']:
                return_string += 'and link to master is up but with slow IO occuring at {0} seconds ago.'.format(
                    str(data['master_last_io_seconds_ago']))
                return_code = 1
            elif data['master_last_io_seconds_ago'] < thresholds['critical']:
                return_string += 'and link to master is up but with VERY SLOW IO occuring at {0} seconds ago.'.format(
                    str(data['master_last_io_seconds_ago']))
                return_code = 2
            perf_data += 'master_last_io_seconds_ago={0}'.format(str(data['master_last_io_seconds_ago']))
        elif data['master_link_status'] == 'down':
            return_string += 'but link to master is DOWN!'
            return_code = 2
        else:
            return_string += 'UNKNOWN Link Status'
            return_code = 3
    else:
        return_string += 'UNKNOWN Role'
        return_code = 3

    return epoch_time, host_name, svc_name, return_code, plugin_output, perf_data


def redis_sentinel_status(epoch_time, svc_name, data, thresholds, nagios_cmd_file):
    '''
    Parser to ingest data received from the redis_sentinel_status beacon.

    Example:
    tag: salt/beacon/redis1.smartaleksolutions.com/redis_sentinel_status/
    data: {
        '_stamp': '2016-11-29T02:06:06.351413',
        'data': {
            'id': 'databank.smartaleksolutions.com',
            'redis_sentinel_status': {
                'master': {
                    'config-epoch': 0,
                    'down-after-milliseconds': 30000,
                    'failover-timeout': 180000,
                    'flags': 'master',
                    'info-refresh': 284,
                    'ip': '172.16.35.228',
                    'is_disconnected': False,
                    'is_master': True,
                    'is_master_down': False,
                    'is_odown': False,
                    'is_sdown': False,
                    'is_sentinel': False,
                    'is_slave': False,
                    'last-ok-ping-reply': 668,
                    'last-ping-reply': 668,
                    'last-ping-sent': 0,
                    'name': 'redis_repl1',
                    'num-other-sentinels': 2,
                    'num-slaves': 1,
                    'parallel-syncs': 1,
                    'pending-commands': 0,
                    'port': 6379,
                    'quorum': 2,
                    'role-reported': 'master',
                    'role-reported-time': 82702154,
                    'runid': 'bb189d2dea98c39ee91369aeeaf453fa93026cb0'
                },
                'sentinels': [
                    {
                        'down-after-milliseconds': 30000,
                        'flags': 'sentinel',
                        'ip': '172.16.35.230',
                        'is_disconnected': False,
                        'is_master': False,
                        'is_master_down': False,
                        'is_odown': False,
                        'is_sdown': False,
                        'is_sentinel': True,
                        'is_slave': False,
                        'last-hello-message': 1843,
                        'last-ok-ping-reply': 668,
                        'last-ping-reply': 668,
                        'last-ping-sent': 0,
                        'name': '172.16.35.230:26379',
                        'pending-commands': 0,
                        'port': 26379,
                        'runid': 'e366454a0635531643f3fefcc45357d815e76120',
                        'voted-leader': '?',
                        'voted-leader-epoch': 0
                    },
                    {
                        'down-after-milliseconds': 30000,
                        'flags': 'sentinel',
                        'ip': '172.16.35.229',
                        'is_disconnected': False,
                        'is_master': False,
                        'is_master_down': False,
                        'is_odown': False,
                        'is_sdown': False,
                        'is_sentinel': True,
                        'is_slave': False,
                        'last-hello-message': 79,
                        'last-ok-ping-reply': 668,
                        'last-ping-reply': 668,
                        'last-ping-sent': 0,
                        'name': '172.16.35.229:26379',
                        'pending-commands': 0,
                        'port': 26379,
                        'runid': '21ef4c823f13cbe574d2c1e134399acc29dbb0a2',
                        'voted-leader': '?',
                        'voted-leader-epoch': 0
                    }
                ],
                'slaves': [
                    {
                        'down-after-milliseconds': 30000,
                        'flags': 'slave',
                        'info-refresh': 284,
                        'ip': '172.16.35.229',
                        'is_disconnected': False,
                        'is_master': False,
                        'is_master_down': False,
                        'is_odown': False,
                        'is_sdown': False,
                        'is_sentinel': False,
                        'is_slave': True,
                        'last-ok-ping-reply': 668,
                        'last-ping-reply': 668,
                        'last-ping-sent': 0,
                        'master-host': '172.16.35.228',
                        'master-link-down-time': 0,
                        'master-link-status': 'ok',
                        'master-port': 6379,
                        'name': '172.16.35.229:6379',
                        'pending-commands': 0,
                        'port': 6379,
                        'role-reported': 'slave',
                        'role-reported-time': 82702150,
                        'runid': 'e1115625ac874c3544bd1f433bf6e9b45a5d6b41',
                        'slave-priority': 100,
                        'slave-repl-offset': 6083052
                    }
                ]
            }
        }
    }
    '''

    host_name = data['id']
    data = data[svc_name]
    master_data = data['master']
    sentinels_data = data['sentinels']
    slaves_data = data['slaves']
    return_string = ''
    return_code = 0
    perf_data = ''

    log.debug("Parsing Redis Status")
    if master_data['is_disconnected'] is not False:
        return_string += 'Master is disconnected!\n'
        return_code = 2
    if master_data['is_master_down'] is not False:
        return_string += 'Master is down!\n'
        return_code = 2
    if master_data['is_odown'] is not False:
        return_string += 'Master is odown!\n'
        return_code = 2
    if master_data['is_sdown'] is not False:
        return_string += 'Master is sdown!\n'
        return_code = 2
    if master_data['num-other-sentinels'] < thresholds['minimum_sentinels']:
        return_string += 'Minimum number of sentinels NOT met! Need {0}, Found {1}!\n'.format(
            str(thresholds['minimum_sentinels']), str(master_data['num-other-sentinels']))
        return_code = 2
    if master_data['num-slaves'] < thresholds['minimum_slaves']:
        return_string += 'Minimum number of slaves NOT met! Need {0}, Found {1}!\n'.format(
            str(thresholds['minimum_slaves']), str(master_data['num-slaves']))
        return_code = 2
    if master_data['quorum'] < thresholds['minimum_quorum']:
        return_string += 'Minimum number of quorem members NOT met! Need {0}, Found {1}\n'.format(
            str(thresholds['minimum_quorum']), str(master_data['minimum_quorum']))
        return_code = 2

    if return_code == 0:
        return_string += 'Master is OK. '

    for sentinel in sentinels_data:
        sentinel_return_code = 0
        if sentinel['is_disconnected'] is not False:
            return_string += 'Sentinel, {0}, is disconnected!\n'.format(sentinel['name'])
            return_code = 2
        if sentinel['is_master_down'] is not False:
            return_string += 'Sentinel, {0}, thinks master is down!\n'.format(sentinel['name'])
            return_code = 2
        if sentinel['is_odown'] is not False:
            return_string += 'Sentinel, {0}, thinks master is odown!\n'.format(sentinel['name'])
            return_code = 2
        if sentinel['is_sdown'] is not False:
            return_string += 'Sentinel, {0}, thinks master is sdown!\n'.format(sentinel['name'])
            return_code = 2

        if sentinel_return_code == 0:
            return_string += 'Sentinel, {0}, is OK. '.format(sentinel['name'])

    for slave in slaves_data:
        slave_return_code = 0
        if slave['is_disconnected'] is not False:
            return_string += 'Slave, {0}, is disconnected!\n'.format(slave['name'])
            return_code = 2
        if slave['is_master_down'] is not False:
            return_string += 'Slave, {0}, thinks master is down!\n'.format(slave['name'])
            return_code = 2
        if slave['is_odown'] is not False:
            return_string += 'Slave, {0}, thinks master is odown!\n'.format(slave['name'])
            return_code = 2
        if slave['is_sdown'] is not False:
            return_string += 'Slave, {0}, thinks master is sdown!\n'.format(slave['name'])
            return_code = 2
        if slave['master-link-status'] != 'ok':
            return_string += 'Master Slave link status of {0} not okay for {1} '.format(slave['master-link-status'],
                                                                                        slave['name'])

        if slave_return_code == 0:
            return_string += 'Slave, {0}, is OK. '.format(slave['name'])

    return epoch_time, host_name, svc_name, return_code, plugin_output, perf_data
