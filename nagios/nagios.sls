# =============================================================================
# SaltStack State File
#
# NAME: nagios/nagios.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.05
#
# PURPOSE: Setup Nagios on CentOS-7
#
# NOTES:
#

{% from 'nagios/init.sls' import nagios with context %}

# Install necessary packages
nagios_install_packages:
  pkg.installed:
    - names:
      - nagios
      - nagios-plugins-all
      - nagios-plugins-nrpe

# This file gets installed with the wrong group ownership.
nagios_config_inc_php:
  file.managed:
    - name: /usr/share/nagios/html/config.inc.php
    - user: root
    - group: nginx
    - replace: False

# Create and load an selinux module that allows nginx to work with fcgi.
# Also set an SELinux boolean that prevents access from nagios to /var/spool/nagios/cmd/nagios.qh
nagios_selinux:
  file.managed:
    - name: /usr/local/src/nagios_nginx_fcgi.te
    - source: salt://nagios/nagios_nginx_fcgi.te
    - user: root
    - group: root
    - mode: 660
  cmd.script:
    - source: salt://selinux/install_module_from_te.sh
    - cwd: /usr/local/src
    - shell: /bin/bash
    - args: nagios_nginx_fcgi
    - creates: /usr/local/src/nagios_nginx_fcgi.pp
  selinux.boolean:
    - name: daemons_enable_cluster_mode
    - value: on
    - persist: True

nagios_nagios_usermod:
  user.present:
    - name: nagios
    - groups:
      - nagios
      - nginx

nagios_nginx_usermod:
  user.present:
    - name: nginx
    - groups:
      - nagios
      - nginx

{% for config in nagios['confd'].iterkeys() %}
nagios_custom_conf_{{ config }}:
  file.managed:
    - name: /etc/nagios/conf.d/{{ config }}.cfg
    - source: salt://nagios/conf.d/{{ config }}.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
        nagios: {{ nagios }}
    - watch_in:
      - service: nagios_nagios_service
{% endfor %}

{% for type, params in nagios['confd']['custom_hosts'].iteritems() %}
{% for x in ['statusmap_image', 'vrml_image', 'icon_image'] %}
nagios_image_{{ params[x] }}:
  file.managed:
    - name: /usr/share/nagios/html/images/logos/{{ params[x] }}
    - source: salt://nagios/logos/{{ params[x] }}
    - user: root
    - group: root
    - mode: 644
{% endfor %}
{% endfor %}

{% for type, nodes in nagios['equipment'].iteritems() %}
{% for node, params in nodes.iteritems() %}
nagios_equipment_{{ type }}_{{ node }}:
  file.managed:
    - name: /etc/nagios/conf.d/equipment/{{ type }}/{{ node }}.cfg
    - source: salt://nagios/conf.d/equipment/node.jinja
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
        nagios: {{ nagios }}
        type: {{ type }}
        node: {{ node }}
    - watch_in:
      - service: nagios_nagios_service
{% endfor %}
{% endfor %}

nagios_config:
  file.managed:
    - name: /etc/nagios/nagios.cfg
    - source: salt://nagios/nagios.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
        nagios: {{ nagios }}

nagios_cgi_config:
  file.replace:
    - name: /etc/nagios/cgi.cfg
    - pattern: '=nagiosadmin'
    - repl: '=*'

nagios_nagios_service:
  service.running:
    - name: nagios
    - enable: True
    - onlyif: /sbin/nagios -v /etc/nagios/nagios.cfg
    - watch:
      - pkg: nagios_install_packages
      - file: nagios_config_inc_php
      - file: nagios_config
      - file: nagios_cgi_config
