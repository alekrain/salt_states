#===============================================================================
# SaltStack State File
#
# NAME: openvpn/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.06.10
#
# PURPOSE: Install and configure OpenVPN
#
# NOTES:
#   2017.06.18 - Only sets up the server. Does not setup client connections.
#
# EXAMPLE PILLAR:
# openvpn:
#   install: true
#   server:
#     config:
#       port: 1194
#       proto: udp
#       dev: tun
#       ca: server/ca.crt
#       cert: server/server.crt
#       key: server/server.key
#       dh: dh.pem
#       server: 10.8.0.0 255.255.255.0
#       ifconfig_pool_persist: ipp.txt
#       push_routes:
#         - "route 192.168.25.0 255.255.255.0"
#       push_options:
#         - "dhcp-option DNS 208.67.220.220"
#         - "dhcp-option DNS 208.67.222.222"
#       keepalive: 10 120
#       cipher: AES-256-CBC
#       compress:
#         alg: lz4-v2
#         push: "compress lz4-v2"
#       max_clients: 100
#       status: /var/log/openvpn-status.log
#       verb: 3
#       explicit_exit_notify:
#     dh: |
#       -----BEGIN DH PARAMETERS-----
#       YOUR DH.PEM GOES HERE
#       -----END DH PARAMETERS-----
#     ca_crt: |
#       -----BEGIN CERTIFICATE-----
#       YOUR CA CERTIFICATE GOES HERE
#       -----END CERTIFICATE-----
#     server_crt: |
#       -----BEGIN CERTIFICATE-----
#       YOUR CERTIFICATE GOES HERE
#       -----END CERTIFICATE-----
#     server_key: |
#       -----BEGIN RSA PRIVATE KEY-----
#       YOUR PRIVATE KEY GOES HERE
#       -----END RSA PRIVATE KEY-----

{% set openvpn = salt.pillar.get('openvpn') %}

openvpn_install:
  pkg.installed:
    - name: openvpn

openvpn_server_config:
  file.managed:
    - name: /etc/openvpn/server.conf
    - source: salt://openvpn/server.conf.jinja
    - template: jinja
    - context:
        openvpn: {{ openvpn.server.config }}
    - user: root
    - group: root
    - mode: 600
    - watch_in:
      - service: openvpn_service

openvpn_dh_params:
  file.managed:
    - name: /etc/openvpn/dh.pem
    - contents_pillar: openvpn:server:dh
    - user: root
    - group: root
    - mode: 600
    - watch_in:
      - service: openvpn_service

openvpn_server_dir:
  file.directory:
    - name: /etc/openvpn/server
    - user: root
    - group: root
    - mode: 700

{% for file, contents in {'ca.crt': 'ca_crt', 'server.key': 'server_key', 'server.crt': 'server_crt'}.iteritems() %}
openvpn_{{ file }}:
  file.managed:
    - name: /etc/openvpn/server/{{ file }}
    - contents_pillar: openvpn:server:{{ contents }}
    - user: root
    - group: root
    - mode: 600
    - watch_in:
      - service: openvpn_service
{% endfor %}

openvpn_service:
  service.running:
    - name: openvpn@server
    - enable: true
