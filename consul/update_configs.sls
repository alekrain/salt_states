# =============================================================================
# SaltStack State File
#
# NAME: consul/update_configs.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.30
#
# PURPOSE: Update the configs for a Consul agent.
#
# NOTES:
#


# Set a variable to the minion_id (This is generally the same as the hostname)
{% set id = salt.grains.get('id') %}
{% set consul = salt.pillar.get('consul') %}

# Add a cronjob to run this saltstack state.
consul_add_update_to_cron:
  cron.present:
    - name: salt-call state.sls update_configs
    - user: root
    - special: '@hourly'
    - identifier: consul_configs_update

# Pull down any and all new configs for the consul agent.
{% if consul['configs'] is defined %}
{% for config in consul['configs'].iterkeys() %}
consul_config_{{ config }}:
  file.serialize:
    - name: /etc/consul.d/{{ config }}.json
    - dataset_pillar: consul:configs:{{ config }}
    - formatter: json
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: consul_reload
{% endfor %}
{% endif %}

# consul_update_configs:
#   file.recurse:
#     - name: /etc/consul.d/
#     - source: salt://consul/configs/{{ id.split('.')[0] }}/
#     - user: root
#     - group: root
#     - dir_mode: 755
#     - file_mode: 644
#     - watch_in:
#       - file: consul_update_configs


# Signal consul agent to reread it's configs but only when a change is detected in consul_update_configs
consul_reload:
  service.running:
    - name: consul
    - enable: true
