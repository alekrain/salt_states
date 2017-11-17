#===============================================================================
# SaltStack State File
#
# NAME: packages/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.05.18
#
# PURPOSE: Install a basic set of packages for systems management.
#
# NOTES:
#

# Import the map.jinja file
{%- from "packages/map.jinja" import base_packages with context %}
{%- from "packages/map.jinja" import version_packages with context %}
{%- from "packages/map.jinja" import development_packages with context %}
{%- from "packages/map.jinja" import pip_packages with context %}
{%- from "packages/map.jinja" import service_packages with context %}

# Refresh packages db once instead of every time a package is installed.
# Could do it this way, but it shows up as a change.
# packages_refresh:
#   module.run:
#     - name: pkg.refresh_db

# Instead we'll refresh by a module call through jinja
{% set refresh = salt.pkg.refresh_db() %}

# Standard need to have packages as well as some nice to have utilities.
packages/init.sls - install base packages:
  pkg.installed:
    - refresh: False
    - names:
{%- for base_package in base_packages %}
      - {{ base_package }}
{%- endfor %}


# Version Packages
packages/init.sls - install version packages:
  pkg.installed:
    - refresh: False
    - names:
{%- for version_package in version_packages %}
      - {{ version_package }}
{%- endfor %}


packages/init.sls - install development packages:
  pkg.installed:
    - refresh: False
    - names:
{%- for development_package in development_packages %}
      - {{ development_package }}
{%- endfor %}


{% for pip_package in pip_packages %}
packages/init.sls - install pip package {{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
{%- endfor %}


{% for package_name, service_name in service_packages.iteritems() %}
packages/init.sls - install package and start service for {{ package_name }}:
  pkg.installed:
    - name: {{ package_name }}
    - refresh: False
  service.running:
    - name: {{ service_name }}
    - enable: true
{%- endfor %}
