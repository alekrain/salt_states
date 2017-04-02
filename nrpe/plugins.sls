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
{% set nrpe = salt.pillar.get('nrpe', {}) %}

# Install all necessary yum packages
{% for package in nrpe['plugins']['packages'] -%}
nrpe_plugins_install_packages:
  pkg.installed:
    - names:
      - {{ package }}
{% endfor -%}

# Install all necessary pip modules
{% for pip_package in nrpe['plugins']['pip_packages'] -%}
nrpe_plugins_install_pip_packages:
  pip.installed:
    - name: {{ pip_package }}
{% endfor -%}

# Copy down the scripts and set the appropriate selinux context
{% for script, se_context in nrpe['plugins']['scripts'].iteritems() -%}
nrpe_plugins_{{ script }}:
  file.managed:
    - name: /usr/lib64/nagios/plugins/{{ script }}
    - source: salt://nrpe/plugins/{{ script }}
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
{% for module in nrpe['plugins']['selinux_te_files'] -%}
nrpe_plugins_selinux_{{ module }}:
  file.managed:
    - name: /usr/local/src/{{ module }}.te
    - source: salt://nrpe/plugins/{{ module }}.te
    - user: root
    - group: root
    - mode: 660
  cmd.script:
    - source: salt://selinux/install_module_from_te.sh
    - cwd: /usr/local/src
    - shell: /bin/bash
    - args: {{ module }}
    - creates: /usr/local/src/{{ module }}.pp
{% endfor -%}

# Set any necessary selinux booleans
{% for boolean, value in nrpe['plugins']['selinux_booleans'].iteritems() -%}
nrpe_plugins_selinux_boolean:
  selinux.boolean:
    - name: {{ boolean }}
    - value: {{ value }}
    - persist: True
{% endfor -%}
