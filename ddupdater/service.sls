#===============================================================================
# SaltStack State File
#
# NAME: {{ sls }}
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.06.18
#
# PURPOSE: Install ddupater.
#
# NOTES:
#   2017.06.18 - Currently, only works with Google Domains.
#
# EXAMPLE PILLAR:
# ddupdater:
  # install: true
  # login: loginkey
  # password: passwordtoken
  # domain_names: managed.smartaleksolutions.com

{% set ddupdater = salt.pillar.get('ddupdater') %}

{{ sls }} - install python requests:
  pkg.installed:
    - name: python2-requests

{{ sls }} - install script:
  file.managed:
    - name: /opt/smrt/ddupdater/ddupdater.py
    - source: salt://ddupdater/files/ddupdater.py.jinja
    - makedirs: true
    - template: jinja
    - defaults:
        ddupdater: {{ ddupdater }}
    - user: ddupdater
    - group: ddupdater
    - mode: 600
    - require:
      - pkg: {{ sls }} - install python requests

{{ sls }} - install service file:
  file.managed:
    - name: /usr/lib/systemd/system/ddupdater.service
    - user: ddupdater
    - group: ddupdater
    - mode: 644
    - require:
      - file: {{ sls }} - install script
    - contents: |
        [Unit]
        Description=Dynamic DNS Updater
        After=network.target

        [Service]
        Type=simple
        RuntimeDirectory=/opt/smrt/ddupdater
        ExecStart=/usr/bin/python2 ddupdater.py
        ExecReload=/bin/kill -HUP $MAINPID

        [Install]
        WantedBy=multi-user.target

{{ sls }} - install log rotate config:
  file.managed:
    - name: /etc/logrotate.d/ddupdater
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: {{ sls }} - install script
    - contents: |
        /var/log/ddupdater.log {
            daily
            missingok
            rotate 7
            compress
            notifempty
        }

{{ sls }} - start service:
  service.running:
    - name: ddupdater
    - enable: true
    - watch:
      - file: {{ sls }} - install service file
      - file: {{ sls }} - install script
