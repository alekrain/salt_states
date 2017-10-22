# =============================================================================
# SaltStack State File
#
# NAME: mysql/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.10.09
#
# PURPOSE: Setup MySQL
#
# EXAMPLE PILLAR:
# mysql:
#   install: true
#   host: 'localhost'
#   port: 3306
#   user: 'root'
#   pass: 'somepass'
#   default_pass: ''
#   db: 'mysql'
#   unix_socket: '/var/lib/mysql/mysql.sock'
#   charset: 'utf8'
#


{% set mysql = salt.pillar.get('mysql') %}
{% set roles = salt.grains.get('roles', []) %}
{% if mysql not in roles %}
  {% do mysql.update({'pass': mysql['default_pass']}) %}
{% endif %}

mysql/init.sls - Install MariaDB package and dependencies, and then start the service:
  pkg.installed:
    - names:
      - mariadb-server
      - python-devel
      - mariadb-devel
  pip.installed:
    - name: MySQL-python
  service.running:
    - name: mariadb
    - enable: true
    - require:
      - pkg: mysql/init.sls - Install MariaDB package and dependencies, and then start the service


{% if mysql['pass'] == mysql['default_pass'] %}
mysql/init.sls - Drop the test database:
  mysql_database.absent:
    - name: test

mysql/init.sls - Set root password:
  mysql_user.present:
    - host: localhost
    - name: root
    - password: mysql['pass']

mysql/init.sls - Set grain for next time:
  grains.append:
    - name: roles
    - value: mysql
    - require:
      - mysql_query: mysql/init.sls - Set root password
      - mysql_query: mysql/init.sls - Drop the test database
{% endif %}
