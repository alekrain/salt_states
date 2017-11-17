# =============================================================================
# SaltStack State File
#
# NAME: kvm/network.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.02.27
#
# PURPOSE: Setup KVM/Libvirt host network configs.
#
# NOTES:
#


{%- set interface = salt.pillar.get('kvm:network') %}

kvm_network_packages:
  pkg.installed:
    - name: bridge-utils

{% for device, params in interface.iteritems() %}
kvm_network_{{ device }}:
  network.managed:
    - name: {{ device }}
    - enabled: {{ params.onboot }}
    - type: {{ params.type }}
{%- if params.bootproto is defined %}
    - proto: {{ params.bootproto }}
{%- endif %}
{%- if params.bridge is defined %}
    - bridge: {{ params.bridge }}
{%- endif %}
{%- if params.delay is defined %}
    - delay: {{ params.delay }}
{%- endif %}
{%- if params.hwaddr is defined %}
    - hwaddr: {{ params.hwaddr }}
{%- endif %}
{%- if params.ipv6init is defined %}
    - enable_ipv6: {{ params.ipv6init }}
{%- endif %}
{%- if params.ports is defined %}
    - ports: {{ params.ports }}
{%- endif %}
{%- if params.userctl is defined %}
    - userctl: {{ params.userctl }}
{%- endif %}
{%- if params.vlan is defined %}
    - vlan: {{ params.vlan }}
{%- endif %}
{%- endfor %} {# for device, params in interface.iteritems() #}
