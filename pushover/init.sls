#===============================================================================
# SaltStack State File
#
# NAME: pushover/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.10.26
#
# PURPOSE: Install script that allows api access to pushover.
#
# CHANGE LOG:

# NOTES:
#

pushover_pushover_notify:
  file.managed:
    - name: /usr/local/libexec/pushover.py
    - source: salt://pushover/pushover.py
    - user: root
    - group: root
    - mode: 775

pushover_install_requests:
  pip.installed:
    - name: requests
    - bin_env: '/usr/bin/pip3'
