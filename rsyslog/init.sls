#===============================================================================
# SaltStack State File
#
# NAME: rsyslog/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.06.26
#
# PURPOSE: Setup rsyslog
#
# EXAMPLE PILLAR:
# rsyslog:
#   install: true
#   server: 192.168.1.1
#   global_directives:
#     - $SystemLogRateLimitInterval 0
#     - $SystemLogRateLimitBurst 0
#   conf_files:
#     firewalld: |
#       if $syslogtag == 'firewalld' and $msg contains 'ERROR' then /var/log/firewalld.err
#       & stop
#     iptables: |
#       ':msg, contains, "IPTABLES ICMP: " /var/log/iptables-icmp.log
#       & stop'
#     saltminion: |
#       # Stop salt-minion going into messages - it already has a log
#       if $programname == 'salt-minion' then stop


{% set rsyslog = salt.pillar.get('rsyslog') %}

# Install rsyslog if it's not already
rsyslog_install:
  pkg.installed:
    - name: rsyslog

# Copy in the rsyslog configuration file.
rsyslog_configuration_file:
  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://rsyslog/rsyslog.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        rsyslog: {{ rsyslog }}
    - require:
      - pkg: rsyslog_install

# Copy in the other conf files
{% if rsyslog['conf_files'] is defined and rsyslog['conf_files'] is iterable %}
{% for conf in rsyslog['conf_files'].iterkeys() %}
logrotated_conf_{{ conf }}:
  file.managed:
    - name: /etc/rsyslog.d/{{ conf }}.conf
    - contents_pillar: rsyslog:conf_files:{{ conf }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: rsyslog_install
    - watch_in:
      - service: rsyslog_service
{% endfor %} {# for conf in rsyslog['conf_files'].iterkeys() #}
{% endif %} {# if rsyslog['conf_files'] is defined and rsyslog['conf_files'] is iterable #}

# Restart the rsyslog service if the configuration file changes
rsyslog_service:
  service.running:
    - name: rsyslog
    - enable: True
    - watch:
      - file: rsyslog_configuration_file
    - require:
      - file: rsyslog_configuration_file
