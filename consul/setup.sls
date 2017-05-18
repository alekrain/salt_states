# =============================================================================
# SaltStack State File
#
# NAME: consul/servers.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.30
#
# PURPOSE: Join a Consul cluster.
#
# NOTES:
#

{% from "consul/map.jinja" import type with context %}
{% from "consul/map.jinja" import params with context %}
{% from "consul/map.jinja" import myip with context %}
{% from "consul/map.jinja" import ips with context %}
{% from "consul/map.jinja" import script_location with context %}
{% from "consul/map.jinja" import script_source with context %}


# Set Grain
consul_setup_set_grain_{{ type }}:
    grains.present:
    - name: 'roles:consul'
    - value: {{ type }}
    - force: true

# Create startup script
consul_setup_conf_{{ type }}:
  file.managed:
    - name: {{ script_location }}
    - source: {{ script_source }}
    - user: consul
    - group: consul
    - mode: 644
    - template: jinja
    - defaults:
        type: {{ type }}

{%- if 'CentOS Linux-7' == salt.grains.get('osfinger') %}
consul_setup_systemd_reload:
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: consul_setup_conf_{{ type }}
{% endif %}


# Create consul config
consul_setup_json_config_{{ type }}:
  file.serialize:
    - name: /etc/consul.d/config.json
    - formatter: json
    - user: consul
    - group: consul
    - mode: 644
    - makedirs: True
    - dataset:
        {%- if params.bootstrap is defined %}
        bootstrap: {{ params.bootstrap }}
        {%- endif %}
        server: {{ params.server }}
        bind_addr: {{ myip }}
        datacenter: {{ params.datacenter }}
        data_dir: {{ params.data_dir }}
        encrypt: {{ params.encrypt }}
        log_level: {{ params.log_level }}
        {%- if type != "bootstrap" %}
        retry_join: {{ ips }}
        {% endif -%}
        {%- if params.ui is defined %}
        ui: {{ params.ui }}
        {% endif -%}
        {%- if params.client_addr is defined %}
        client_addr: {{ params.client_addr }}
        {% endif %}

# Start consul agent.
consul_setup_start_{{ type }}:
  service.running:
    - name: consul
    - enable: true
    - watch:
      - file: consul_setup_conf_{{ type }}
      - file: consul_setup_json_config_{{ type }}

# Remove grain if this is the current bootstrap server.
{% if 'bootstrap' in salt.grains.get('roles:consul') %}
consul_setup_remove_bootstrap_grain:
  grains.present:
    - name: 'roles:consul'
    - value: bootstrap
    - force: true
    - reload_grains: true
{% endif %}
