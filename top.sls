#===============================================================================
# SaltStack Top File
#
# NAME: top.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.06
#
# PURPOSE: Salt top.sls
#
#
# NOTES:
#

base:
  'G@os:CentOS':
    - disable
    - packages
    - users
    - sudoers
    - sshd_config
    - minion
    - selinux
    - udr

  # 'consul:install:true':
  #   - match: pillar
  #   - consul

  'crontab:install:true':
    - match: pillar
    - crontab

  'ddupdater:install:true':
    - match: pillar
    - ddupdater

  'dnsmasq:install:true':
    - match: pillar
    - dnsmasq

  'engines:install:true':
    - match: pillar
    - engines

  'fail2ban:install:true':
    - match: pillar
    - fail2ban

  'kernel_params:install:true':
    - match: pillar
    - kernel_params

  # 'iptables:install:true':
  #   - match: pillar
  #   - iptables

  'master:install:true':
    - match: pillar
    - master

  'nagios:install:true':
    - match: pillar
    - nagios

  'nrpe:install:true':
    - match: pillar
    - nrpe

  'nfs:install:true':
    - match: pillar
    - nfs

  'openvpn:install:true':
    - match: pillar
    - openvpn

  'plex:install:true':
    - match: pillar
    - plex

  'pushover:install:true':
    - match: pillar
    - pushover

  'rclone:install:true':
    - match: pillar
    - rclone

  'routing:install:true':
    - match: pillar
    - routing

  'rsyslog:install:true':
    - match: pillar
    - rsyslog

  'sumologic:install:true':
    - match: pillar
    - sumologic

  'sync:install:true':
    - match: pillar
    - sync

  'zfs:install:true':
    - match: pillar
    - zfs
