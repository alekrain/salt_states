# =============================================================================
# SaltStack State File
#
# NAME: engines/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.08.10
#
# PURPOSE: Deploy engine configurations.
#
# CHANGE LOG:
#
# NOTES:
#
# EXAMPLE PILLAR:
# engines:
#   - nagios_passive_ingest:
#       nagios_cmd_file: /var/spool/nagios/cmd/nagios.cmd
#       thresholds:
#         mongo_replset_status:
#           ok: 0
#         rabbitmq_queue_checker:
#           critical: 100000
#           warning: 80000
#           ok: 79999
#         redis_repl_status:
#           critical: 30
#           warning: 15
#           ok: 5
#         redis_sentinel_status:
#           minimum_sentinels: 2
#           minimum_slaves: 1
#           minimum_quorum: 2
#         salt_minion_heartbeat:
#           critical: 60
#           warning: 20
#           ok: 0

{% set delay = salt.pillar.get('engines:delay', '10') %}

# Calling refresh_pillar and sync_engines through jinja so they don't
# show up as changes. This is kinda hacky but saltutil doesn't exist as a
# state module so here we are.
{% set refresh_pillar = salt.saltutil.refresh_pillar() %}
{% set refresh_engines = salt.saltutil.sync_engines() %}

engines_create_config:
  file.managed:
    - name: /etc/salt/minion.d/_engines.conf
    - contents_pillar: engines:conf
    - user: root
    - group: root
    - mode: 644

engines_restart_minion:
  at.present:
    - job: service salt-minion restart
    - timespec: now + {{ delay }} minutes
    - user: root
    - onchanges:
      - file: engines_create_config
