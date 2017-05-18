# =============================================================================
# SaltStack State File
#
# NAME: consul/base.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.30
#
# PURPOSE: Base setup for all Consul servers.
#
# NOTES:
#


# Copy down and extract the consul binary.
consul_base_extract_binary:
  archive.extracted:
    - name: /usr/local/sbin/
    - source: https://releases.hashicorp.com/consul/0.8.3/consul_0.8.3_linux_amd64.zip
    - source_hash: sha256=f894383eee730fcb2c5936748cc019d83b220321efd0e790dae9a3266f5d443a
    - enforce_toplevel: false
    - user: root
    - group: root

{% if not salt.grains.get('roles:consul') %}
consul_base_create_consul_role:
  grains.present:
    - name: roles:consul
    - value: []
    - force: true
{% endif %}

consul_base_create_user:
  group.present:
    - name: consul
  user.present:
    - name: consul
    - gid_from_name: True
    - hash_password: consul

consul_base_mkdir_data:
  file.directory:
    - name: /var/consul
    - user: consul
    - group: consul
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - clean: False
