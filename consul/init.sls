# =============================================================================
# SaltStack State File
#
# NAME: consul/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.04.03
#
# PURPOSE: Join a Consul cluster.
#
# NOTES:
#

{% if 'consul' in salt.grains.get('roles') %}
include:
  - consul.base
  - consul.setup
  - consul.update_configs
{% endif %}
