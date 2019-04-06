#===============================================================================
# SaltStack State File
#
# NAME: {{ sls }}
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.10.02
#
# PURPOSE: Install ZFS on Centos7
#

{% set os_release_as_list = salt.grains.get('osrelease').split('.') %}
{% set os_release_underscore = os_release_as_list[0] + "_" os_release_as_list[1] %}
{% set os_release_dot = os_release_as_list[0] + "." os_release_as_list[1] %}

{{ sls }} - Install ZFS release package:
  pkg.installed:
    - sources:
      - zfs-release: http://download.zfsonlinux.org/epel/zfs-release.el{{ os_release_underscore }}.noarch.rpm

{{ sls }} - Install ZFS:
  pkg.installed:
    - name: zfs

{{ sls }} - Install ZFS YUM repo file:
  file.managed:
    - name: /etc/yum.repos.d/zfs.repo
    - source: salt://zfs/files/zfs.repo.jinja
    - template: jinja
    - context:
        os_release = {{ os_release_dot }}
    - user: root
    - group: root
    - mode: 644

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
