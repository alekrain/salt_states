# =============================================================================
# SaltStack Orchestration File
#
# NAME: consul/create_cluster.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.30
#
# PURPOSE: Create a Consul cluster on Linux based systems.
#
# NOTES:
#   Things to fix:
#    - Sleeps would be better if they were reactors instead.
#    - There's nothing that prevents the update_configs from restarting all nodes simultaneously.
#   Resetting in the event that all nodes go down.
#    From salt-master:
#      - salt 'consul*' grains.delval roles
#      - salt-run state.orch consul.create_cluster
#

{% set consul1 = 'consul1.smartaleksolutions.com' %}
{% set consul23 = 'consul[23].smartaleksolutions.com' %}

# Do basic things that all Consul nodes will need.
consul_create_cluster_base:
  salt.state:
    - tgt: consul*
    - sls: consul.base

# # Set Bootstrap Grain
# consul_create_cluster_bootstrap_grain:
#   salt.function:
#     - tgt: {{ consul1 }}
#     - name: grains.set
#     - kwarg:
#         key: 'roles:consul'
#         val: 'bootstrap'
#         force: true
#
# # Set Server Grains
# consul_create_cluster_server_grain:
#   salt.function:
#     - tgt: {{ consul23 }}
#     - name: grains.set
#     - kwarg:
#         key: 'roles:consul'
#         val: 'server'
#         force: true

# Start the bootstrap agent.
consul_create_cluster_bootstrap:
  salt.state:
    - tgt: 'roles:consul:bootstrap'
    - tgt_type: grain
    - sls: consul.setup

# Start server agents and join them to the cluster.
consul_create_cluster_servers:
  salt.state:
    - tgt: 'roles:consul:server'
    - tgt_type: grain
    - sls: consul.setup

# Replace bootstrap grain
# consul_create_cluster_replace_bootstrap_grain:
#   salt.function:
#     - tgt: {{ consul1 }}
#     - name: grains.set
#     - kwarg:
#         key: 'roles:consul'
#         val: server
#         force: true

# Replace the bootstrap config
consul_create_cluster_replace_bootstrap:
  salt.state:
    - tgt: {{ consul1 }}
    - sls: consul.setup

# Update the configs for all the consul servers
consul_update_configs_consul1:
  salt.state:
    - tgt: {{ consul1 }}
    - sls: consul.update_configs

# Terrible I know, but it keeps the cluster from freaking out.
consul_create_cluster_sleep_consul1:
  salt.function:
    - tgt: {{ consul1 }}
    - name: test.sleep
    - kwarg:
        length: 5

consul_update_configs_consul23:
  salt.state:
    - tgt: {{ consul23 }}
    - sls: consul.update_configs
