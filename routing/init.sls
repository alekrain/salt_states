# =============================================================================
# SaltStack State File
#
# NAME: routing/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.10.04
#
# PURPOSE: Added routes.
#
# NOTES:
#
# EXAMPLE PILLAR:
# routing:
#   install: true
#   routes:
#     1:
#       eth0:
#         - route_name: openvpn_network
#           ipaddr: 10.8.0.0
#           netmask: 255.255.255.0
#           gateway: 172.16.8.253


{%- set routing = salt.pillar.get('routing:routes') %}

{%- for name, route in routing.iteritems() %}
routing/init.sls - set additional routes for host {{ name }}:
  network.routes:
    - name: {{ route.interface }}
    - routes:
      - name: {{ name }}
        ipaddr: {{ route.ipaddr }}
        netmask: {{ route.netmask }}
        gateway: {{ route.gateway }}
{%- endfor %}
