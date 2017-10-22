# =============================================================================
# SaltStack State File
#
# NAME: wordpress/wordpress.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.19
#
# PURPOSE: Setup Wordpress with Nginx
#
# NOTES:
#

{% set wordpress = salt.pillar.get('wordpress') %}

wordpress/init.sls - install packages:
  pkg.installed:
      - name: php-mysql

wordpress/init.sls - get the latest wordpress:
  archive.extracted:
    - name: /opt
    - source: https://wordpress.org/latest.zip
    - skip_verify: true
    - user: root
    - group: root
    - if_missing: /opt/wordpress

wordpress/init.sls - Create symlink:
  file.symlink:
    - name: /usr/share/nginx/html/wordpress
    - target: /opt/wordpress

wordpress/init.sls - Copy in the wp-config template:
  file.managed:
    - name: /opt/wordpress/wp-config.php
    - source: salt://wordpress/files/wp-config.php.jinja
    - template: jinja
    - defaults:
        wordpress: {{ wordpress }}
    - user: root
    - group: root
    - mode: 644
