# ==============================================================================
# SaltStack State File
#
# NAME: dnsmasq/init.sls
# VERSION: 1.0
# DATE  : 2016.04.28
#
# PURPOSE: Setup DNSMasq
#
# CHANGE LOG:
#
# NOTES:
#
# EXAMPLE PILLAR:
  # dnsmasq:
  #   install: true
  #   dhcp_boot: pxelinux.0,dnsmasq.smartaleksolutions.com,192.168.1.254
  #   interface: eth0
  #   no_dhcp_interface: eth0
  #   resolv_file: /etc/resolv.dnsmasq
  #   resolv_conf: |
  #     search smartaleksolutions.com
  #     nameserver 208.67.220.220
  #     nameserver 208.67.222.222
  #   hosts:
  #     TNA:
  #       router: 192.168.1.1
  #       server1: 192.168.1.2


{% set dnsmasq = salt.pillar.get('dnsmasq', {}) %}

# Install Package
dnsmasq_install:
  pkg.installed:
    - name: dnsmasq

# Set Configuration
dnsmasq_conf_file:
  file.managed:
    - name: /etc/dnsmasq.conf
    - source: salt://dnsmasq/dnsmasq.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        dnsmasq: {{ dnsmasq }}

# Set resolv.dnsmasq config
dnsmasq_resolv_conf:
  file.managed:
    - name: /etc/resolv.dnsmasq
    - contents_pillar: dnsmasq:resolv_conf
    - user: root
    - group: root
    - mode: 644

# Set the hosts file
dnsmasq_hosts_file:
  file.managed:
    - name: /etc/dnsmasq.hosts
    - source: salt://dnsmasq/dnsmasq.hosts.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        hosts: {{ dnsmasq['hosts'] }}

# Ensure service is running
dnsmasq_service_runnning:
  service.running:
    - name: dnsmasq
    - enable: true
    - watch:
      - file: dnsmasq_conf_file
      - file: dnsmasq_resolv_conf
      - file: dnsmasq_hosts_file
