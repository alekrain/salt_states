# =============================================================================
# SaltStack State File
#
# NAME: nginx/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE: 2016.02.27
#
# PURPOSE: Setup nginx
#
# NOTES: In the Pillar, only the certbot or self section is needed for TLS.
#
# EXAMPLE PILLAR:
#
# nginx:
#   install: true
#   common_name: salt.smartaleksolutions.com
#   conf:
#     user: nginx
#     worker_processes: auto
#     error_log: /var/log/nginx/error.log
#     pid: /var/run/nginx.pid
#     include: /usr/share/nginx/modules/*.conf
#     events: worker_connections 1024
#     http:
#       access_log: /var/log/nginx/access.log  main
#       sendfile: "on"
#       tcp_nopush: "on"
#       tcp_nodelay: "on"
#       keepalive_timeout: 65
#       types_hash_max_size: 2048
#       include: /etc/nginx/conf.d/*.conf
#       server:
#         listen:
#           - 80 default_server
#           - "[::]:80 default_server"
#         root: /usr/share/nginx/html
#         index: index.html index.htm
#         include: /etc/nginx/default.d/*.conf
#         error_page:
#           404:
#             page: /404.html
#             location: /40x.html
#           500 502 503 504:
#             page: /50x.html
#             location: /50x.html
#   tls:
#     email: noc@smartaleksolutions.com
#     certbot:
#       listen: 443 ssl
#     self:
#       listen: 443 ssl
#       tls_dir: tls
#       bits: 2048
#       country: US
#       state: GA
#       locality: Woodsticks
#       organization: SmartAlek Solutions
#       organizational_unit: DevOps
#       cacert_path: /etc/pki
#       digest: sha256
#       replace: false


include:
  - .nginx
  - .tls
  - .auth
