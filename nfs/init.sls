# =============================================================================
# SaltStack State File
#
# NAME: nfs/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.13
#
# PURPOSE: Install NFS.
#
# NOTES:
#
# EXAMPLE PILLAR:
# nfs:
#   install: true
#   exports: |
#     /mnt/storage/Videos 192.168.1.250(ro,async,no_root_squash)
#     /mnt/storage/Photos 192.168.1.250(ro,async,no_root_squash)
#     /mnt/storage/Music 192.168.1.250(ro,async,no_root_squash)
#     /mnt/storage/Movies 192.168.1.250(ro,async,no_root_squash)
#

nfs_install_utils:
  pkg.installed:
    - name: nfs-utils

nfs_exports:
  file.managed:
    - name: /etc/exports
    - contents_pillar: nfs:exports
    - user: root
    - group: root
    - mode: 644

nfs_service:
  service.running:
    - name: nfs
    - enable: true
    - watch:
      - file: nfs_exports
