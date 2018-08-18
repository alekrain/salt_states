# =============================================================================
# SaltStack State File
#
# NAME: {{ sls }}
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.13
#
# PURPOSE: Install rClone and setup script to rclone and rsync files.
#
# EXAMPLE PILLAR:
#    sync:
#      install: true
#      rclone:
#        conf: |
#          [backblaze]
#          type = b2
#          account = 01234abc
#          key = 0123456789abcdefghijklmnopqrstuvwxyz012345
#          endpoint =
#        version: rclone-v1.38-linux-amd64
#        shasum: '69bcd262f6e67eaa9f28f93460d73ad8a73612745d3c7a2bdd03d4cf85d43090'
#        targets: [ "Stuff" ]
#      rsync:
#        targets: [ "Stuff", "More Stuff"]

{% set sync = salt.pillar.get('sync') %}

{{ sls }} - download and unzip the rclone archive:
  archive.extracted:
    - name: /usr/local/src/
    - source: https://downloads.rclone.org/rclone-current-linux-amd64.zip
    - source_hash: sha256={{ sync.rclone.shasum }}
    - user: root
    - group: root
    - if_missing: /usr/local/src/{{ sync.rclone.version }}
    - unless: if ls /usr/local/src/rclone*/rclone; then exit 0; else exit 1; fi

{{ sls }} - create symlink to rclone binary:
  file.symlink:
    - name: /usr/local/sbin/rclone
    - target: /usr/local/src/{{ sync.rclone.version }}/rclone
    - user: root
    - group: root

{{ sls }} - make sure conf directories exist:
  file.directory:
    - name: /root/.config/rclone
    - user: root
    - group: root
    - dir_mode: 770
    - makedirs: true

{{ sls }} - install rclone configuration file:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - contents_pillar: rclone:conf
    - user: root
    - group: root
    - mode: 600

{{ sls }} - setup script to call rclone:
  file.managed:
    - name: /root/sync.sh
    - source: salt://{{ sls }}/files/rclone.sh.jinja
    - template: jinja
    - defaults:
      - rclone: {{ sync.rclone }}
      - rsync: {{ sync.rsync }}
    - user: root
    - group: root
    - mode: 750

{{ sls }} - setup cron job:
  cron.present:
    - user: root
    - identifier: Sync
    - comment: Sync files using rClone and rSync
    - name: /bin/bash /root/sync.sh
    - minute: 1
    - hour: 4
