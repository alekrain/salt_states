# =============================================================================
# SaltStack State File
#
# NAME: salt/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.07.19
#
# PURPOSE: Install the salt repo and update salt minion to latest version.
#
# CHANGE LOG:
#
# NOTES:
#   Available Repos:
#     Latest: https://repo.saltstack.com/yum/redhat/salt-repo-latest-1.el7.noarch.rpm
#     Major: https://repo.saltstack.com/yum/redhat/salt-repo-2016.11-1.el7.noarch.rpm
#


salt_install_repo:
  pkg.installed:
    - sources:
      - salt-repo: https://repo.saltstack.com/yum/redhat/salt-repo-2016.11-1.el7.noarch.rpm

salt_install_salt_minion:
  pkg.latest:
    - name: salt-minion
    - require:
      - pkg: salt_install_repo

salt_install_start_minion:
  service.running:
    - name: salt-minion
    - enable: True

salt_install_setup_restart:
  cmd.run:
    - name: echo service salt-minion restart | at now + 10 minutes
    - onchanges:
      - pkg: salt_install_salt_minion
