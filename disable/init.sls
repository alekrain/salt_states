# =============================================================================
# SaltStack State File
#
# NAME: disable/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.10.09
#
# PURPOSE: Disable services that are not needed.
#
# NOTES:
#
# EXAMPLE PILLAR:
# disable:
#   services:
#     - NetworkManager
#     - firewalld
#

{% set disable = salt.pillar.get('disable:services') %}

{% for service in disable.iterkeys() %}
disable_service_{{ service }}:
  service.dead:
    - name: {{ service }}
    - enable: False
{% endfor %}
