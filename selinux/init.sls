#===============================================================================
# SaltStack State File
#
# NAME: selinux/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.11.12
#
# PURPOSE: Setup selinux
#
# EXAMPLE PILLAR:
# selinux:
#   mode: enforcing
#   booleans:
#     selinux_boolean1: 1
#     selinux_boolean2: 1
#   semodules:
#     - newmodule1
#     - newmodule2


{% set selinux = salt.pillar.get('selinux', {}) %}

selinux/init.sls - et the selinux mode:
  selinux.mode:
    - name: {{ selinux.mode }}

{% if selinux['booleans'] is defined %}
  {% for boolean, value in selinux['booleans'].iteritems() %}
selinux/init.sls - set boolean {{ boolean }}:
  selinux.boolean:
    - name: {{ boolean }}
    - value: {{ value }}
    - persist: true
  {% endfor %}
{% endif %}

{% if selinux['modules'] is defined %}
  {% for module in selinux['modules'] %}
selinux/init.sls - install selinux module {{ module }}:
  selinux.module_install:
    - name: salt://selinux/files/{{ module }}
  {% endfor %}
{% endif %}
