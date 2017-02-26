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
{% from "packages/map.jinja" import base_packages with context %}
{% from "packages/map.jinja" import version_packages with context %}
{% from "packages/map.jinja" import development_packages with context %}
{% from "packages/map.jinja" import pip_packages with context %}
{% from "packages/map.jinja" import service_packages with context %}


# Standard need to have packages as well as some nice to have utilities.
{% for base_package in base_packages %}
{{ base_package }}:
  pkg.installed:
    - names: []
{% endfor %}

# Version Packages
{% for version_package in version_packages %}
{{ version_package }}:
  pkg.installed:
    - names: []
{% endfor %}

{% for development_package in development_packages %}
{{ development_package }}:
  pkg.installed:
    - names: []
{% endfor %}

{% for pip_package in pip_packages %}
{{ pip_package }}:
  pip.installed:
    - name: []
{% endfor %}

{% for package_name, service_name in service_packages.iteritems() %}
{{ package_name }}:
  pkg.installed: []
  service.running:
    - name: {{ service_name }}
    - enable: True
{% endfor %}
