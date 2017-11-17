#===============================================================================
# SaltStack State File
#
# NAME: zfs/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.10.02
#
# PURPOSE: Install ZFS on Centos7
#


zfs/init.sls - Install ZFS release package:
  pkg.installed:
    - sources:
      - zfs-release: http://download.zfsonlinux.org/epel/zfs-release.el7_4.noarch.rpm

zfs/init.sls - Install ZFS:
  pkg.installed:
    - name: zfs
