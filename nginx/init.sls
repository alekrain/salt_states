# =============================================================================
# SaltStack State File
#
# NAME: nginx/init.sls
# VERSION: 1.0
# DATE  : 2016.02.27
#
# PURPOSE: Setup nginx
#
# CHANGE LOG:
#
# EXAMPLE PILLAR:
# nginx:
#   install: true
#   auth:
#     alek: helloworld
#   tls:
#     lets_encrypt:
#       privkey: |
#         -----BEGIN PRIVATE KEY-----
#         YOUR PRIVATE KEY
#         -----END PRIVATE KEY-----
#       fullchain: |
#         -----BEGIN CERTIFICATE-----
#         YOUR FULL CERTIFICATE CHAIN
#         -----END CERTIFICATE-----
#       cert: |
#         -----BEGIN CERTIFICATE-----
#         YOUR CERTIFICATE
#         -----END CERTIFICATE-----
#       chain: |
#         -----BEGIN CERTIFICATE-----
#         YOUR CHAIN
#         -----END CERTIFICATE-----
#     self_signed: true
#       tls_dir: some/dir
#       bits: 2048
#       country: US
#       state: GA
#       locality: Woodsticks
#       organization: SmartAlek Solutions
#       organizational_unit: IT
#       email: support@smartaleksolutions.com
#       cacert_path: some/dir
#       digest: sha256
#       replace: false


include:
  - .nginx
  - .tls
  - .auth
