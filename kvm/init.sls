#===============================================================================
# SaltStack State File
#
# NAME: kvm/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.10.06
#
# PURPOSE: Setup KVM/Libvirt
#
# NOTES:
#   2015.10.06 - Tested to work with CentOS7.
#
# EXAMPLE PILLAR:
# kvm:
#   install: true
#   ksm:
#     ksm_thres_coef
#   network:
#     br0:
#       bootproto: none
#       delay: 200
#       ipv6init: no
#       onboot: yes
#       type: bridge
#       userctl: no
#     eno1:
#       bootproto: dhcp
#       ipv6init: no
#       onboot: yes
#       type: eth
#       userctl: no

include:
  - kvm.kvm
  - kvm.network
