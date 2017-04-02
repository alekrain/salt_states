#===============================================================================
# SaltStack State File
#
# NAME: sshd_config/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.06.30
#
# PURPOSE: Ensure SSH is installed running with the correct config params.
#
# NOTES:
#   Configs use the following options:
      # secure
      #   no root login
      #   no passwords
      #   no UseDNS
      #   yes pubkey auth
      # insecure
      #   yes root login
      #   yes pubkey auth
      #   yes password auth
      #   no use dns
      # moderate
      #   yes root login
      #   no passwords
      #   no UseDNS
      #   yes pubkey auth

#

{% from "sshd_config/map.jinja" import sshd_params with context %}

sshd_installed:
  pkg.installed:
    - name: {{ sshd_params.sshd_package }}

# Copy the SSHd configuration to the server
sshd_config_file:
  file.managed:
    - name: {{ sshd_params.config }}
    - source: salt://sshd_config/sshd_config_centos.jinja
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - defaults:
        permit_root_login: "{{ sshd_params.permit_root_login }}"
        gssapi_cleanup_credentials: "{{ sshd_params.gssapi_cleanup_credentials }}"
        use_privilege_separation: "{{ sshd_params.use_privilege_separation }}"
        password_authentication: "{{ sshd_params.password_authentication }}"
        pubkey_authentication : "{{ sshd_params.pubkey_authentication }}"
        use_dns : "{{ sshd_params.use_dns }}"
    - require:
      - pkg: sshd_installed

# Restart the sshd service
sshd_restart:
  service.running:
    - name: {{ sshd_params.servicename }}
    - watch:
       - file: sshd_config_file
