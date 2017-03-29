# =============================================================================
# SaltStack State File
#
# NAME: python3/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.06.14
#
# PURPOSE: Install Python3
#
# CHANGE LOG:
#
# NOTES:
#

python3_install:
  pkg.installed:
    - names:
      - python34
      - python34-devel
      - python34-pip

# Before python34-pip package was available, I used this.
# python3_pip_install:
#   cmd.script:
#     - source: salt://python3/python3_pip_install.py
#     - shell: /bin/bash
