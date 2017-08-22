# =============================================================================
# SaltStack State File
#
# NAME: wordpress/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.19
#
# PURPOSE: Setup Wordpress with Nginx
#
# NOTES:
#

wordpress_wordpress_get_wordpress:
  archive.extracted:
    - name: /usr/share/nginx/html
    - source: https://wordpress.org/latest.zip
    - skip_verify: true
    - user: root
    - group: root
    - if_missing: /usr/share/nginx/html/wordpress
