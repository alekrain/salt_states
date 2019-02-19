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
# fail2ban:
#   install: true
#   services:
#     default:
#       ignoreip: 127.0.0.1/32
#       bantime: 604800
#       findtime: 300
#       maxretry: 3
#       banaction: iptables-ipset-proto6
#       banaction_allports: iptables-ipset-proto6-allports
#     sshd:
#       enabled: true
#       port: 22
#       logpath: '%(sshd_log)s'
#       backend: '%(sshd_backend)s'
#


{% set fail2ban = salt.pillar.get('fail2ban') %}

# Install fail2ban packages
{{ sls }} - install package:
  pkg.installed:
    - names:
      - fail2ban-server

{% for service, params in fail2ban.services.iteritems() %}
{{ sls }} - install jail.local file for {{ service }}:
  file.managed:
    - name: /etc/fail2ban/jail.d/{{ service }}.local
    - source: salt://fail2ban/files/jail.local.jinja
    - template: jinja
    - defaults:
        services: {{ fail2ban.services }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: {{ sls }} - install package
    - watch_in:
      - service: {{ sls }} - service running
{% endfor %}

{{ sls }} - service running:
  service.running:
    - name: fail2ban
    - enable: True
