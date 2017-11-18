# =============================================================================
# SaltStack State File
#
# NAME: minion/init.sls
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
#     Major: https://repo.saltstack.com/yum/redhat/salt-repo-2016.11-2.el7.noarch.rpm
#

{% set minion = salt.pillar.get('minion') %}
{% set latest_version = salt.pkg.latest_version('salt-minion') %}

minion/init.sls - install salt repo:
  pkg.installed:
    - sources:
      - salt-repo: https://repo.saltstack.com/yum/redhat/salt-repo-2016.11-2.el7.noarch.rpm

minion/init.sls - setup the minion config:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://minion/files/minion.jinja
    - template: jinja
    - defaults:
        minion: {{ minion }}
    - user: root
    - group: root
    - mode: 644

minion/init.sls - ensure minion is set to run and that it is running:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - file: minion/init.sls - setup the minion config
      - pkg: minion/init.sls - install salt repo

{% if latest_version != "" and latest_version.split('-')[0] != salt.grains.get('saltversion') %}
minion/init.sls - update the minion if necessary:
  cmd.run:
    - name: echo 'yum -y update salt-minion && service salt-minion restart' | at now + 20 minutes
    - watch_in:
      - service: minion/init.sls - ensure minion is set to run and that it is running 
{% endif %}