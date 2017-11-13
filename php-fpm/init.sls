# =============================================================================
# SaltStack State File
#
# NAME: php-fpm/php-fpm.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.10.09
#
# PURPOSE: Setup php-fpm
#
# NOTES:
#

{% set phpfpm = salt.pillar.get('phpfpm') %}

php-fpm/init.sls - install packages:
  pkg.installed:
    - name: php-fpm

php-fpm/init.sls - fix path info setting:
  file.replace:
    - name: /etc/php.ini
    - pattern: ';?(cgi\.fix_pathinfo)=1'
    - repl: '\1=0'

php-fpm/init.sls - template the php-fpm www.conf file:
  file.managed:
    - name: /etc/php-fpm.d/www.conf
    - source: salt://php-fpm/files/www.conf.jinja
    - template: jinja
    - defaults:
        phpfpm: {{ phpfpm }}
    - user: root
    - group: root
    - mode: 644

php-fpm/init.sls - start PHP service:
  service.running:
    - name: php-fpm
    - enable: true
    - watch:
      - file: php-fpm/init.sls - fix path info setting
      - file: php-fpm/init.sls - template the php-fpm www.conf file
