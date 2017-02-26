#===============================================================================
# SaltStack State File
#
# NAME: udr/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.10.04
#
# PURPOSE: Install UDR.
#
# NOTES:
#   2015.10.04 - Tested to work with CentOS7
#   2017.02.25 - There are multiple methods for install. If the OS is CentOS 6
#     or CentOS 7, only the compiled binary is copied over. Else, the source
#     will be pulled from git, or extracted from the udr.tar.gz file.
#

{% set os = salt.grains.get('osfinger') %}

# Install necessary packages
udr_packages:
  pkg.installed:
    - names:
      - openssl-devel
      - gcc-c++

# Determine if we can just ship the binary
{% if os == 'CentOS Linux-7' or os == 'CentOS-6' -%}
udr_download_bin:
  file.managed:
    - name: /usr/local/src/UDR/src/udr
    - source: salt://udr/udr.bin
    - source_hash: sha256=9fff49242df697df8e5b90fc50718c6aee2dfc403271476625858d5dcd488125
    - makedirs: True
    - user: root
    - group: root
    - mode: 770

{%- else %}
# Git Clone the latest version of UDR to the server
udr_download_git:
  git.latest:
    - name: https://github.com/LabAdvComp/UDR.git
    - rev: f549f4afce3c49d8dbd1fb30cbf8d6755f8aa80b
    - target: /usr/local/src/UDR
    - unless: test -d /usr/local/src/UDR
    - require_in:
      - cmd: udr_install

# If you prefer to use a premade UDR archive instead of cloning from Github.
# Or if Github isn't available.
udr_download_tar:
  archive.extracted:
    - name: /usr/local/src/UDR
    - source: salt://udr/udr.tar.gz
    - archive_format: tar
    - options: xzf
    - enforce_toplevel: False
    - require_in:
      - cmd: udr_install
    - onfail:
      - git: udr_download_git
    - unless:
      - test -d /usr/local/src/UDR

# Now that we have the source, install.
udr_install:
  cmd.run:
    - name: |
        make -C ./udt/ -e arch=AMD64
        make -C ./src/ -e arch=AMD64
    - cwd: /usr/local/src/UDR
    - timeout: 300
    - unless: test -x /usr/local/bin/udr
{%- endif %}

# Make UDR available in the path
udr_symlink:
  file.symlink:
    - name: /usr/local/bin/udr
    - target: /usr/local/src/UDR/src/udr
  require:
    - cmd: udr_install
