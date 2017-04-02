#===============================================================================
# SaltStack State File
#
# NAME: nrpe/setup.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.04.02
#
# PURPOSE: Install NRPE and setup it's config file.
#
# NOTES:
#


# Get the nrpe pillar data
{% set nrpe = salt.pillar.get('nrpe') %}

# Preallocate the user, group, and some folders.
nrpe_gid:
  group.present:
    - name: nagios
    - gid: 900

nrpe_uid:
  user.present:
    - name: nagios
    - uid: 900
    - gid: 900
    - require:
      - group: nrpe_gid

# Make sure the NRPE package is installed after the nrpe user and group have been setup.
nrpe_install:
  pkg.installed:
    - names:
      - nrpe
      - nagios-plugins-all
    - require:
      - group: nrpe_gid
      - user: nrpe_uid

# Drop in the nrpe.cfg file specific for this host or the the default.
nrpe_config_file:
  file.managed:
    - name: /etc/nagios/nrpe.cfg
    - source: salt://nrpe/nrpe.cfg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        nagios_server: {{ nrpe['nagios_server'] }}
        command_timeout: {{ nrpe['command_timeout'] }}
        connection_timeout: {{ nrpe['connection_timeout'] }}
        checks: {{ nrpe['checks'] }}
