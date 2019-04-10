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

{% set gcp_fru = salt.pillar.get('gcp-fru') %}

{{ sls }} - install script:
  file.managed:
    - name: /opt/smrt/gcp-fru/gcp-firewall-rules-updater.py
    - source: salt://gcp-firewall-rules-updater/files/gcp-firewall-rules-updater.py.jinja
    - makedirs: true
    - template: jinja
    - defaults:
        project: {{ gcp_fru.project }}
        rule: {{ gcp_fru.rule }}
        domain: {{ gcp_fru.domain }}
    - user: gcp-fru
    - group: gcp-fru
    - mode: 600

{{ sls }} - install service file:
  file.managed:
    - name: /usr/lib/systemd/system/gcp-firewall-rules-updater.service
    - user: gcp-fru
    - group: gcp-fru
    - mode: 644
    - require:
      - file: {{ sls }} - install script
    - contents: |
        [Unit]
        Description=GCP Firewall Rules Updater
        After=network.target

        [Service]
        Type=simple
        WorkingDirectory=/opt/smrt/gcp-fru
        ExecStart=/usr/bin/python2 /opt/smrt/gcp-fru/gcp-firewall-rules-updater.py
        ExecStop=/bin/kill $MAINPID

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
        /var/log/gcp-firewall-rules-updater.log {
            daily
            missingok
            rotate 7
            compress
            notifempty
        }

{{ sls }} - start service:
  service.running:
    - name: gcp-firewall-rules-updater
    - enable: true
    - watch:
      - file: {{ sls }} - install service file
      - file: {{ sls }} - install script
