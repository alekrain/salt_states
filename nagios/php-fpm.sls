# =============================================================================
# SaltStack State File
#
# NAME: nagios/php_fpm.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.05
#
# PURPOSE: Setup PHP-FPM on CentOS-7
#
# NOTES:
#


nagios_php_fpm_install_packages:
  pkg.installed:
    - names:
      - php-fpm

# Fix the 'fix_pathinfo' variable so php is not totally insecure.
nagios_php_fpm_ini_fix_pathinfo:
  file.append:
    - name: /etc/php.ini
    - text: cgi.fix_pathinfo=0

# Reconfigure the php-fpm www.conf so it works with nginx.
nagios_php_fpm_www_conf_listen:
  file.replace:
    - name: /etc/php-fpm.d/www.conf
    - pattern: '^listen\s=\s127.0.0.1:9000$'
    - repl: 'listen = /var/run/php-fpm/php-fpm.sock'
    - count: 1

nagios_php_fpm_www.conf_user:
  file.replace:
    - name: /etc/php-fpm.d/www.conf
    - pattern: '^user\s=\sapache$'
    - repl: 'user = nginx'
    - count: 1

nagios_php_fpm_www.conf_group:
  file.replace:
    - name: /etc/php-fpm.d/www.conf
    - pattern: '^group\s=\sapache$'
    - repl: 'group = nginx'
    - count: 1

nagios_php_fpm_www_conf_uncomment_owner:
  file.uncomment:
    - name: /etc/php-fpm.d/www.conf
    - regex: 'listen.owner\s=\snobody$'
    - char: ';'

nagios_php_fpm_www_conf_uncomment_group:
  file.uncomment:
    - name: /etc/php-fpm.d/www.conf
    - regex: 'listen.group\s=\snobody$'
    - char: ';'
