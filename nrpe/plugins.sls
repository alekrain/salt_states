#===============================================================================
# SaltStack State File
#
# NAME: nrpe/plugins.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.04.02
#
# PURPOSE: Setup custom plugins.
#
# NOTES:
#


# Get the nrpe pillar data
{% set nrpe_plugins = salt.pillar.get('nrpe:plugins', {}) %}

# Install all necessary yum packages
nrpe_plugins_install_packages:
  pkg.installed:
    - names:
{%- for package in nrpe_plugins['packages'] %}
      - {{ package }}
{%- endfor %}

# Install all necessary pip modules
{% for pip2_package in nrpe_plugins['pip2_packages'] -%}
nrpe_plugins_install_{{ pip2_package }}:
  pip.installed:
    - name: {{ pip2_package }}
    - bin_env: /bin/pip2
{% endfor -%}

{% for pip3_package in nrpe_plugins['pip3_packages'] -%}
nrpe_plugins_install_{{ pip3_package }}:
  pip.installed:
    - name: {{ pip3_package }}
    - bin_env: /bin/pip3
{% endfor -%}

# Copy down the scripts and set the appropriate selinux context
{% for script, se_context in nrpe_plugins['scripts'].iteritems() -%}
nrpe_plugins_{{ script }}:
  file.managed:
    - name: /usr/lib64/nagios/plugins/{{ script }}
    - source: salt://nrpe/files/{{ script }}
    - user: root
    - group: root
    - mode: 755
  module.wait:
    - name: file.set_selinux_context
    - path: /usr/lib64/nagios/plugins/{{ script }}
    - type: {{ se_context }}
    - watch:
      - file: nrpe_plugins_{{ script }}
{% endfor -%}

# Create and load an selinux module that allows nagios to run a plugin.
{% for module in nrpe_plugins['selinux_te_files'] -%}
nrpe_plugins_selinux_{{ module }}:
  file.managed:
    - name: /usr/local/src/{{ module }}.te
    - source: salt://nrpe/files/{{ module }}.te
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - source: salt://selinux/files/create_policy.sh
    - template: jinja
    - cwd: /usr/local/src
    - defaults:
        module: {{ module }}
    - onchanges:
      - file: nrpe_plugins_selinux_{{ module }}
  selinux.module_install:
    - name: /usr/local/src/{{ module }}.pp
    - onchanges:
      - cmd: nrpe_plugins_selinux_{{ module }}
{% endfor -%}

# Set any necessary selinux booleans
{% for boolean, value in nrpe_plugins['selinux_booleans'].iteritems() -%}
nrpe_plugins_selinux_boolean:
  selinux.boolean:
    - name: {{ boolean }}
    - value: {{ value }}
    - persist: True
{% endfor -%}
