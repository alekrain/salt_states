# =============================================================================
# SaltStack State File
#
# NAME: hosts/grain_roles.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.12.07
#
# PURPOSE: Append entries into hosts file for other hosts that use the same
#    role. This is useful in clusters to avoid DNS issues.
#
# NOTES:
#   Requires that the network.ipaddrs mine is deployed.
#   See: https://docs.saltstack.com/en/latest/topics/mine/
#

{%- set roles = salt.grains.get('roles') %}
{%- for role in roles %}
{%- for host, ips in salt.mine.get(tgt='roles:' + role, fun='network.ip_addrs', expr_form='grain').iteritems() %}
{%- for ip in ips %}
hosts_{{ role }}_{{ host }}_{{ ip }}:
  file.append:
    - name: /etc/hosts
    - text: {{ ip }}   {{ host }}
{%- endfor %}
{%- endfor %} {# for host in hosts #}
{%- endfor %} {# for role in roles #}
