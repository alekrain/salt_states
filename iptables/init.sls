# =============================================================================
# SaltStack State File
#
# NAME: iptables/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.06.06
#
# PURPOSE: Install IPTables rules.
#
# NOTES: There is always a SPECIAL chain in the filter table. This gives a
#   jump point for rules defined in another pillar file.
#
# EXAMPLE PILLAR:
# iptables:
#   install: false
#   flush: true
#   ipsets:
#     install: true
#     flush: true
#     sets:
#       ALLOW_LOCAL:
#         type: "hash:net"
#         entries:
#           - 192.168.1.0/24 # Local Range
#   ruleset:
#     filter:
#       INPUT:
#         - loopback:
#             in_interface: lo
#             jump: ACCEPT
#         - related_established:
#             match: state
#             connstate: RELATED,ESTABLISHED
#             jump: ACCEPT
#         - jump_to_SPECIAL:
#             jump: SPECIAL
#         - jump_to_COMMON:
#             jump: COMMON
#       COMMON:
#         - nrpe_from_nagios:
#             source: 192.168.1.254
#             proto: tcp
#             dport: 5666
#             match: state
#             connstate: NEW
#             jump: ACCEPT
#         - icmp_from_nagios:
#             source: 192.168.1.254
#             proto: icmp
#             icmp_type: 8
#             jump: ACCEPT
#         - allow_ssh:
#             matchset: ALLOW_LOCAL src
#             proto: tcp
#             dport: 22
#             match: state
#             connstate: NEW
#             jump: ACCEPT
#
# EXAMPLE OTHER PILLAR FILE
# iptables:
#   ruleset:
#     filter:
#       SPECIAL:
#         - jump_to_DNS:
#             jump: DNS
#       DNS:
#         - allow_dns_tcp:
#             matchset: ALLOW_LOCAL src
#             proto: tcp
#             dport: 53
#             connstate: NEW
#             jump: ACCEPT
#         - allow_dns_udp:
#             matchset: ALLOW_LOCAL src
#             proto: udp
#             dport: 53
#             connstate: NEW
#             jump: ACCEPT
#


include:
  - iptables/ipset
  - iptables/iptables
  - iptables/rules
