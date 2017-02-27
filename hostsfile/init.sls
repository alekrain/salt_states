# =============================================================================
# SaltStack State File
#
# NAME: hostsfile/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# VERSION: 1.0
# DATE  : 2016.12.07
#
# PURPOSE: Append entries into hosts file.
#
# CHANGE LOG:
#
# Pillar Structure:
#   hostsfile:
#     entries:
#       host1: ip
#       host2: ip


{% for host, ip in salt.pillar.get('hostsfile:entries').iteritems() %}
hostsfile_{{ host }}_{{ ip }}:
  file.append:
    - name: /etc/hosts
    - text: {{ ip }}    {{ host }}
{% endfor %}
