# =============================================================================
# SaltStack State File
#
# NAME: wordpress/nginx.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.19
#
# PURPOSE: Setup Wordpress with Nginx
#
# NOTES:
#


{% set wordpress = salt.pillar.get('wordpress') %}
{% set minion_id = salt.grains.get('id') %}

wordpress_nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://wordpress/files/nginx.conf.jinja
    - template: jinja
    - user: nginx
    - group: nginx
    - mode: 644
    - defaults:
        wordpress: {{ wordpress }}

wordpress_nginx_service:
  service.running:
    - name: nginx
    - reload: true
    - enable: true
    - watch:
      - file: wordpress_nginx_config
