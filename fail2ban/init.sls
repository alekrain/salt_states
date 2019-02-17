#=========================================================================================
# SaltStack State File
#
# NAME: fail2ban/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 201
#
# PURPOSE: Install and configure fail2ban
#
# EXAMPLE PILLAR:
#   fail2ban:
#     install: true
#     jail:
#       ssh_enabled: true
#       ignoreip: 127.0.0.1/8
#       bantime: 604800
#       findtime: 300
#       maxretry: 3
#       backend: auto
#       usedns: warn
#       logencoding: auto
#       chain: INPUT
#       banaction: iptables-ipset-proto6
#       banaction_allports: iptables-ipset-proto6-allports
#


{% set fail2ban = salt.pillar.get('fail2ban') %}

# Install fail2ban packages
fail2ban/init.sls - install package:
  pkg.installed:
    - names:
      - fail2ban-server

{% for service, params in fail2ban.services.iteritems() %}
fail2ban/init.sls - install jail.local file for {{ service }}:
  file.managed:
    - name: /etc/fail2ban/jail.d/{{ service }}.local
    - source: salt://fail2ban/files/jail.local.jinja
    - template: jinja
    - defaults:
        services: {{ fail2ban.services }}
    - user: root
    - group: root
    - mode: 644
  require:
    - pkg: fail2ban/init.sls - install package
{% endfor %}

fail2ban_restart:
  service.running:
    - name: fail2ban
    - enable: True
    - watch:
      - file: fail2ban/init.sls - install jail config file
