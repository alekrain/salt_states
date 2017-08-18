# =============================================================================
# SaltStack State File
#
# NAME: iptables/ipset/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.06.10
#
# PURPOSE: Configure ipset
#
# NOTES:
#   Its a bit janky to have the if statement after the pkg.install, but it's the
#   only way I can have the iptables.sls require this sls in a way that works.
#

{% set iptables = salt.pillar.get('iptables') %}

ipsets_install:
  pkg.installed:
    - name: ipset

{% if iptables['ipsets'] is defined and iptables.ipsets.install is defined %}
{% if iptables.ipsets.install == true %}
  {% set ipsets = iptables.ipsets %}
  {% set sets = ipsets.sets %}

ipsets_startstop_script:
  file.managed:
    - name: /usr/libexec/ipsets/ipsets.start-stop
    - source: salt://iptables/ipsets/ipsets.start-stop
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

ipsets_systemd_config:
  file.managed:
    - name: /etc/systemd/system/ipsets.service
    - source: salt://iptables/ipsets/ipsets.service
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

ipsets_systemd_reload:
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: ipsets_systemd_config

  {% for set_name, set in sets.iteritems() %}
ipsets_present_{{ set_name }}:
  ipset.set_present:
    - name: {{ set_name }}
    - set_type: {{ set.type }}

    {% if ipsets['flush'] == true %}
ipsets_flush_{{ set_name }}:
  ipset.flush:
    - name: {{ set_name }}
    {% endif %}

    {% for entry in set.entries %}
ipsets_add_{{ set_name }}_{{ entry }}:
  ipset.present:
    - set_name: {{ set_name }}
    - entry: {{ entry }}
    {% endfor %} {# for entry in set.entries #}
  {% endfor %} {# for set_name, set in ipsets.iteritems() #}
{% endif %} {# if iptables['ipsets:install'] == true #}
{% endif %} {# if iptables['ipsets'] is defined #}
