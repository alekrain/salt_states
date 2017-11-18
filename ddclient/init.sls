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
  # login: loginkey
  # password: passwordtoken
  # domain_names: nagios.alektant.com

{% set ddclient = salt.pillar.get('ddclient') %}

ddclient/init.sls - install:
  pkg.installed:
    - name: ddclient

ddclient/init.sls - setup config file:
  file.managed:
    - name: /etc/ddclient.conf
    - source: salt://ddclient/ddclient.conf.jinja
    - template: jinja
    - defaults:
        ddclient: {{ ddclient }}
    - user: ddclient
    - group: ddclient
    - mode: 600
    - require:
      - pkg: ddclient/init.sls - install

ddclient/init.sls - start service:
  service.running:
    - name: ddclient
    - enable: true
    - watch:
      - file: ddclient/init.sls - setup config file