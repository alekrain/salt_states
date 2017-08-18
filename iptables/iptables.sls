# =============================================================================
# SaltStack State File
#
# NAME: iptables/iptables.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.06.06
#
# PURPOSE: Install IPtables rules.
#
# NOTES:
#


{% set iptables = salt.pillar.get('iptables') %}
{% if iptables.install == true %}

iptables_installed:
  pkg.installed:
    - name: iptables-services
    - require:
      - sls: iptables/ipsets
  service.enabled:
    - name: iptables
    - require:
      - pkg: iptables_installed

{% for table in iptables['ruleset'].iterkeys() %}
{% for chain in iptables['ruleset'][table].iterkeys() %}
iptables_{{ table }}_{{ chain }}_present:
  iptables.chain_present:
    - table: {{ table }}
    - name: {{ chain }}
    - require:
      - service: iptables_installed

{% if iptables.flush is defined and iptables.flush == True %}
iptables_{{ table }}_{{ chain }}_flush_{{ loop.index }}:
  iptables.flush:
    - table: {{ table }}
    - name: {{ chain }}
    - require:
      - iptables: iptables_{{ table }}_{{ chain }}_present
{% endif %} {#  if iptables.flush is defined and iptables.flush == True #}
{% endfor %} {#  for chain in iptables['ruleset'][table].iterkeys() #}
{% endfor %} {#  for table in iptables['ruleset'].iterkeys() #}

iptables_filter_SPECIAL_present_jic:
  iptables.chain_present:
    - table: filter
    - name: SPECIAL
    - require:
      - service: iptables_installed

{% if iptables.flush is defined and iptables.flush == True %}
iptables_filter_SPECIAL_flush:
  iptables.flush:
    - table: filter
    - name: SPECIAL
    - require:
      - iptables: iptables_filter_SPECIAL_present
{% endif %} {# if iptables.flush is defined and iptables.flush == True #}
{% endif %} {# if iptables.install == True #}
