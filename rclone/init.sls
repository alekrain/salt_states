# =============================================================================
# SaltStack State File
#
# NAME: rclone/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.13
#
# PURPOSE: Install rClone.
#
# EXAMPLE PILLAR:
#    rclone:
#      install: true
#      version: 'rclone-v1.38-linux-amd64'
#      shasum: '69bcd262f6e67eaa9f28f93460d73ad8a73612745d3c7a2bdd03d4cf85d43090'
#      conf: |
#        [backblaze]
#        type = b2
#        account = 01234abc
#        key = 0123456789abcdefghijklmnopqrstuvwxyz012345
#        endpoint =
#

{% set rclone = salt.pillar.get('rclone') %}

rclone/init.sls - download and unzip the rclone archive:
  archive.extracted:
    - name: /usr/local/src/
    - source: https://downloads.rclone.org/rclone-current-linux-amd64.zip
    - source_hash: sha256={{ rclone.shasum }}
    - user: root
    - group: root
    - if_missing: /usr/local/src/{{ rclone.version }}
    - unless: if ls /usr/local/src/rclone*/rclone; then exit 0; else exit 1; fi

rclone/init.sls - create symlink to rclone binary:
  file.symlink:
    - name: /usr/local/sbin/rclone
    - target: /usr/local/src/{{ rclone.version }}/rclone
    - user: root
    - group: root

rclone/init.sls - make sure conf directories exist:
  file.directory:
    - name: /root/.config/rclone
    - user: root
    - group: root
    - dir_mode: 770
    - makedirs: true

rclone/init.sls - install rclone configuration file:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - contents_pillar: rclone:conf
    - user: root
    - group: root
    - mode: 600
