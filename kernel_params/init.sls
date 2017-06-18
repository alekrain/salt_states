#===============================================================================
# SaltStack State File
#
# NAME: kernel_params/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.09.29
#
# PURPOSE: Add kernel parameters.
#
# NOTES:
#
# EXAMPLE PILLAR:
# kernel_params:
#   install: true
#   params:
#     net.ipv6.conf.all.disable_ipv6: 1
#     net.netfilter.nf_conntrack_max: 1048576
#     net.nf_conntrack_max: 1048576
#   echos:
#     /etc/modprobe.d/nf_conntrack: "options nf_conntrack hashsize=262144"


{% set kernel = salt.pillar.get('kernel_params') %}
{% set params = kernel.params %}
{% set echos = kernel.echos %}

{% if params is defined %}
{% for param, value in params.iteritems() %}
kernel_param_{{ param }}:
  sysctl.present:
    - name: {{ param }}
    - value: {{ value }}
{% endfor %}
{% endif %}

{% if echos is defined %}
{% for name, param in echos.iteritems() %}
kernel_param_{{ name }}:
  file.managed:
    - name: {{ name }}
    - contents: {{ param }}
{% endfor %}
{% endif %}
