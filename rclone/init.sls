# =============================================================================
# SaltStack State File
#
# NAME: rclone/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.13
#
# PURPOSE: Install rClone.
#
# NOTES:
#
# EXAMPLE PILLAR:
#

{% set rclone = salt.pillar.get('rclone') %}

rclone_archive_unzip:
  archive.extracted:
    - name: /usr/local/src/
    - source: https://downloads.rclone.org/rclone-current-linux-amd64.zip
    - source_hash: sha256={{ rclone.shasum }}
    - user: root
    - group: root
    - if_missing: /usr/local/src/{{ rclone.version }}
    - unless: if ls /usr/local/src/rclone*/rclone; then exit 0; else exit 1; fi

rclone_symlink:
  file.symlink:
    - name: /usr/local/sbin/rclone
    - target: /usr/local/src/{{ rclone.version }}/rclone
    - user: root
    - group: root

rclone_conf:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - contents_pillar: rclone:conf
    - user: root
    - group: root
    - mode: 600
