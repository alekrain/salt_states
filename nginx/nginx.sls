# =============================================================================
# SaltStack State File
#
# NAME: nginx/nginx.sls
# VERSION: 1.0
# DATE  : 2016.02.27
#
# PURPOSE: Setup nginx
#
# CHANGE LOG:
#
# NOTES:
#

{% set nginx = salt.pillar.get('nginx') %}

nginx/init.sls - Install packages:
  pkg.installed:
    - names:
      - nginx
      - httpd-tools

nginx/init.sls - Install the primary conf file:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf.jinja
    - template: jinja
    - defaults:
        conf: {{ nginx.conf }}
    - user: nginx
    - group: nginx
    - mode: 644
    - require:
      - pkg: nginx/init.sls - Install packages

nginx/init.sls - Start the service:
  service.running:
    - name: nginx
    - enable: true
    - watch:
      - file: nginx/init.sls - Install the primary conf file
