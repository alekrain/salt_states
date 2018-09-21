#===============================================================================
# SaltStack State File
#
# NAME: redis/init.sls
# VERSION: 1.0
# DATE  : 2016.04.05
#
# PURPOSE: Install Redis
#
# EXAMPLE PILLAR:
# redis:
#   install: True
#   conf:
#     bind: {{ ''.join(salt.saltutil.runner('mine.get', tgt=salt.grains.get('id'), fun='network.ip_addrs', tgt_type='glob').itervalues()|first) }}
#     requirepass: SOMEPASSWORD
#     port: 6379
#     min_slaves_to_write: 1
#     min_slaves_max_lag: 10
#     tcp_keepalive: 60
#   replication:
#     primary: redis1.smartaleksolutions.com
#     secondaries:
#       - redis2.smartaleksolutions.com
#     arbiters:
#       - arbiter.smartaleksolutions.com
#   sentinel:
#     redis_repl1:
#       ip: {{ ''.join(salt.saltutil.runner('mine.get', tgt=primary, fun='network.ip_addrs', tgt_type='glob').itervalues()|first) }}
#       port: 6379
#       quorum: 2
#       down_after_milliseconds: 30000
#       failover_timeout: 180000
#       parallel_syncs: 1
#   ssh_keys:
#     id_rsa: |
#         -----BEGIN RSA PRIVATE KEY-----
#         PRIVATE KEY STUFF
#         -----END RSA PRIVATE KEY-----
#     id_rsa.pub: 'ssh-rsa PUBKEY STUFF'

# EXAMPLE PILLAR SLAVES ONLY SECTION:
# redis:
#   conf:
#     slaveof:
#       masterip: None
#       masterport: 6379
#     masterauth: ByKf8EJFNAmF^G&WshgCEj$C3f8yv99k&hS7$!2@6!qAZB!*JMjMGBrsPFhch6pa
#     slave_serve_stale_data: 'yes'




{% set redis = salt.pillar.get('redis') %}
{% if redis.conf.slaveof is defined %}
{% set masterip = ''.join(salt.mine.get(tgt=salt.pillar.get('redis:replication:primary'), fun='network.ip_addrs', expr_form='glob').itervalues()|first) %}
{% do redis.conf.slaveof.update({'masterip': masterip}) %}
{% endif %}

# Install packages
redis_packages:
  pkg.installed:
    - names:
      - gcc
      - python-devel
      - python2-pip
      - hiredis
      - hiredis-devel
      - redis

# Install python packages
redis_python_packages_hiredis:
  pip.installed:
    - name: hiredis
    - require:
      - pkg: redis_packages

redis_python_packages_redis:
  pip.installed:
    - name: redis
    - require:
      - pkg: redis_packages

{% if redis.ssh_keys is defined %}
{% for k, v in redis.ssh_keys.iteritems() %}
redis_ssh_file_{{ k }}:
  file.managed:
    - name: /root/.ssh/{{ k }}
    - contents_pillar: redis:ssh_keys:{{ k }}
    - makedirs: True
    - mode: 600
    - user: root
    - group: root
{% endfor %} {# for k, v in redis.ssh_keys #}
{% endif %} {# if redis.ssh_keys is defined #}

{% if redis.conf.bind is defined %}
redis_conf:
  file.managed:
    - name: /etc/redis.conf
    - source: salt://redis/redis.jinja
    - user: redis
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        redis: {{ redis }}
    - require:
      - pkg: redis_packages
      - pip: redis_python_packages_hiredis
      - pip: redis_python_packages_redis

redis_service:
  service.running:
    - name: redis
    - enable: true
    - watch:
      - file: redis_conf
{% endif %} {# if redis.bind is defined #}


{% if redis.sentinel is defined %}
{% for sentinel, params in redis.sentinel.iteritems() %}
redis_sentinel_selinux_port:
  cmd.run:
    - name: semanage port -a -t redis_port_t -p tcp {{ params.port }}
    - unless: semanage port -l | grep 6379
    - onchanges:
      - pkg: redis_packages
{% endfor %} {# for sentinel, params in redis.sentinel.iteritems() #}

redis_sentinel_selinux:
  file.managed:
    - name: /root/custom_redis-sentinel.pp
    - source: salt://redis/custom_redis-sentinel.pp
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: semodule -i custom_redis-sentinel.pp
    - cwd: /root
    - onchanges:
      - file: redis_sentinel_selinux

sentinel_conf:
  file.managed:
    - name: /etc/redis-sentinel.conf
    - source: salt://redis/redis-sentinel.jinja
    - user: redis
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        redis: {{ redis }}
    - require:
      - pkg: redis_packages
      - pip: redis_python_packages_hiredis
      - pip: redis_python_packages_redis

sentinel_service:
  service.running:
    - name: redis-sentinel
    - enable: true
    - watch:
      - file: sentinel_conf

{% endif %}{# if redis.sentinel is defined #}
