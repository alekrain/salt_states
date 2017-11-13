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


wordpress/nginx.sls - Install phpfpm configuration for nginx:
  file.managed:
    - name: /etc/nginx/default.d/phpfpm.conf
    - source: salt://wordpress/files/nginx_phpfpm.conf
    - user: nginx
    - group: nginx
    - mode: 644

wordpress/nginx.sls - Ensure nginx is running:
  service.running:
    - name: nginx
    - reload: true
    - enable: true
    - watch:
      - file: wordpress/nginx.sls - Install phpfpm configuration for nginx
