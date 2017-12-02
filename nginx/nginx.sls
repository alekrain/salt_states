# =============================================================================
# SaltStack State File
#
# NAME: nginx/nginx.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.02.27
#
# PURPOSE: Setup nginx
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
        nginx: {{ nginx }}
    - user: nginx
    - group: nginx
    - mode: 644
    - require:
      - pkg: nginx/init.sls - Install packages

{%- for dir in ['/usr/share/nginx/modules', '/etc/nginx/conf.d', '/etc/nginx/default.d'] %}
nginx/init.sls - make sure supporting dir exists - {{ dir }}:
  file.directory:
    - name: {{ dir }}
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: true
{%- endfor %}

nginx/init.sls - Start the service:
  service.running:
    - name: nginx
    - enable: true
    - watch:
      - file: nginx/init.sls - Install the primary conf file
