# =============================================================================
# SaltStack State File
#
# NAME: ntp/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.05.18
#
# PURPOSE: Install NTP and setup it's configuration file.
#
# NOTES:
#
# EXAMPLE PILLAR:
# ntp:
#   install: True
#   timezone: America/New_York
#   share:
#     - restrict default limited kod nomodify notrap nopeer noquery
#     - restrict -6 default limited kod nomodify notrap nopeer noquery
#   servers:
#     - 0.pool.ntp.org
#     - 1.pool.ntp.org
#     - 2.pool.ntp.org
#     - 3.pool.ntp.org


{% set ntp = salt.pillar.get('ntp') %}

# Set UTC and change to the appropriate timezone.
ntp_timezone:
  timezone.system:
    - name: {{ ntp.timezone }}
    - utc: True

# Install and configure NTP
ntp_install:
  pkg.installed:
    - name: ntp
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://ntp/ntp.jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - defaults:
        servers: {{ ntp.servers }}
        share: {{ ntp.share }}
    - require:
      - pkg: ntp_install

# Make sure NTPd is running
ntp_running:
  service.running:
    - name: ntpd
    - enable: true
    - require:
      - pkg: ntp_install
      - file: ntp_install
    - watch:
      - cmd: ntp_update_time

# Update clock if necessary.
ntp_update_time:
  service.dead:
    - name: ntpd
    - onlyif:
      - "ntpstat | grep -E '(time correct to within [0-9]{5,} ms)|(^unsynchronised$)'"
  cmd.run:
    - name: ntpdate {{ ntp.servers|first }}
    - onchanges:
      - service: ntp_update_time
