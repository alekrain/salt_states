# =============================================================================
# SaltStack State File
#
# NAME: iptables/rules.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.06.06
#
# PURPOSE: Install IPtables rules.
#
# NOTES:
#


{%- set iptables = salt.pillar.get('iptables') %}

{%- if iptables.install == true %}
{%- for table in iptables['ruleset'].iterkeys() %}
{%- for chain in iptables['ruleset'][table].iterkeys() %}
{%- for rules in iptables['ruleset'][table][chain] %}
{%- for name, params in rules.iteritems() -%}

iptables_{{ table }}_{{ chain }}_{{ name }}_{{ loop.index }}:
  iptables.append:
    - save: true
    - require:
      - sls: iptables/iptables
      - iptables: iptables_{{ table }}_{{ chain }}_present
    - table: {{ table }}
    - chain: {{ chain }}
    - jump: {{ params.jump }}
  {%- if params.source is defined %}
    - source: {{ params.source }}
  {% endif -%}
  {%- if params.destination is defined %}
    - destination: {{ params.destination }}
  {% endif -%}
  {%- if params.proto is defined %}
    - proto: {{ params.proto }}
  {% endif -%}
  {%- if params.sport is defined %}
    - sport: {{ params.sport }}
  {% endif -%}
  {%- if params.dport is defined %}
    - dport: {{ params.dport }}
  {% endif -%}
  {%- if params.to_destination is defined %}
    - to-destination: {{ params.to_destination }}
  {% endif -%}
  {%- if params.in_interface is defined %}
    - in-interface: {{ params.in_interface }}
  {% endif -%}
  {%- if params.out_interface is defined %}
    - out-interface: {{ params.out_interface }}
  {% endif -%}
  {%- if params.icmp_type is defined %}
    - icmp-type: {{ params.icmp_type }}
  {% endif -%}
  {%- if params.to_source is defined %}
    - to-source: {{ params.to_source }}
  {% endif -%}
  {%- if params.tcpflags is defined %}
    - tcp-flags: {{ params.tcpflags }}
  {% endif -%}
  {%- if params.logprefix is defined %}
    - log-prefix: {{ params.logprefix }}
  {% endif -%}
  {%- if params.setxmark is defined %}
    - set-xmark: {{ params.setxmark }}
  {% endif -%}
  {%- if params.to_ports is defined %}
    - to-ports: {{ params.to_ports }}
  {% endif -%}
  {%- if params.matchset is defined %}
    - match-set: {{ params.matchset }}
  {% endif -%}
  {%- if params.match is defined %}
    - match: {{ params.match }}
    {%- if params.comment is defined %}
    - comment: {{ params.comment }}
    {% endif -%}
    {%- if params.connstate is defined %}
    - connstate: {{ params.connstate }}
    {% endif -%}
    {%- if params.dports is defined %}
    - dports: {{ params.dports }}
    {% endif -%}
    {%- if params.string is defined %}
    - string: '"{{ params.string }}"'
    - algo: {{ params.algo }}
    - to: {{ params.to }}
    {% endif -%}
    {%- if params.mark is defined %}
    - mark: {{ params.mark }}
    {% endif -%}
  {% endif -%}
{% endfor %} {# for name, params in rules.iteritems() #}
{% endfor %} {# for rules in iptables['ruleset'][table][chain] #}
{% endfor %} {# for chain in iptables['ruleset'][table].iterkeys() #}
{%- endfor %} {# for table in iptables['ruleset'].iterkeys() #}

iptables_drop_all:
  iptables.append:
    - save: true
    - table: filter
    - chain: INPUT
    - jump: DROP
    - require:
      - sls: iptables/iptables
      - iptables: iptables_filter_INPUT_present

{%- endif %} {# if iptables.install == True #}
