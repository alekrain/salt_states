#===============================================================================
# SaltStack State File
#
# NAME: nrpe/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.05.18
#
# PURPOSE: Install NRPE, setup it's config file, and install custom plugins.
#
# NOTES:
#   Pillar should look similar to:
    # nrpe:
    #   install: True
    #   checks:
    #     - command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
    #     - command[check_load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
    #     - command[check_root]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /
    #     - command[check_boot]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /boot
    #     - command[check_zombie_procs]=/usr/lib64/nagios/plugins/check_procs -w 5 -c 10 -s Z
    #     - command[check_total_procs]=/usr/lib64/nagios/plugins/check_procs -w 150 -c 200
    #     - command[check_uptime]=/usr/bin/python3 /usr/lib64/nagios/plugins/check_uptime.py -lh 2 -gd 30
    #     - command[check_version]=/usr/lib64/nagios/plugins/check_version.sh
    #     - command[check_shm]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/shm
    #   command_timeout: 60
    #   connection_timeout: 300
    #   nagios_server: {{ salt.dig.A('nagios') }}
    #   plugins:
    #     packages: []
    #     pip_packages:
    #       - uptime
    #     scripts:
    #       check_uptime.py: nagios_unconfined_plugin_exec_t
    #       check_version.sh: nagios_unconfined_plugin_exec_t
    #     selinux_te_files:
    #       - check_uptime_py.te
    #     selinux_booleans:
    #       some_boolean: (on || off)
#


# Get the nrpe pillar data
{% set nrpe = salt.pillar.get('nrpe') %}

# Install custom plugins
include:
  - nrpe.setup
  - nrpe.plugins

# Make sure NRPE is running.
nrpe_running:
  service.running:
    - name: nrpe
    - enable: True
    - watch:
      - sls: nrpe.setup
      - sls: nrpe.plugins
