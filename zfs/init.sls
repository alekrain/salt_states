#===============================================================================
# SaltStack State File
#
# NAME: {{ sls }}
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.10.02
#
# PURPOSE: Install ZFS on Centos7
#


{{ sls }} - Install ZFS release package:
  pkg.installed:
    - sources:
      - zfs-release: http://download.zfsonlinux.org/epel/zfs-release.el7_4.noarch.rpm

{{ sls }} - Install ZFS:
  pkg.installed:
    - name: zfs

{{ sls }} - cronjob to mount zpool:
  cron.present:
    - identifier: zpool_mount
    - comment: Mount Zpool Storage on Boot
    - name: modprobe zfs && zpool import storage
    - special: '@reboot'

{{ sls }} - cronjob to scrub storage:
  cron.present:
    - identifier: scrub_storage
    - comment: Weekly Scrub of Storage Pool
    - name: zpool scrub storage
    - minute: 0
    - hour: 21
    - dayweek: 7

{{ sls }} - cronjob to check and log zpool status:
  file.directory:
    - name: /var/log/zfs
    - user: root
    - group: root
  cron.present:
    - identifier: zpool_status
    - comment: Log the status of the zpool
    - name: zpool status > /var/log/zfs/zpool.log
    - minute: 0
