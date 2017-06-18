#===============================================================================
# SaltStack State File
#
# NAME: ddclient/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.06.18
#
# PURPOSE: Install ddclient.
#
# NOTES:
#   2017.06.18 - Currently, only works with Google Domains.
#
# EXAMPLE PILLAR:
# ddclient:
  # install: true
  # protocol: googledomains
  # login: wVUuII2dTM27HcCh
  # password: 6UDfaKO6RB0NRCbQ
  # domain_names: nagios.alektant.com


ddclient_install:
  pkg.installed:
    - name: ddclient

ddclient_conf_file:
  file.managed:
    - name: /etc/ddclient.com
    - source: salt://ddclient/ddclient.conf.jinja
    - template: jinja
    - user: ddclient
    - group: ddclient
    - mode: 600
    - require:
      - pkg: ddclient_install

ddclient_service:
  service.running:
    - name: ddclient
    - enable: true
    - watch:
      - file: ddclient_conf_file
