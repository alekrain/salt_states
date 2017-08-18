#===============================================================================
# SaltStack State File
#
# NAME: sudoers/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE: 2015.06.15
#
# PURPOSE: Modify a few lines of sudoers file to make administration easier.
#
# NOTES:
#

sudoers_installed:
  pkg.installed:
    - name: sudo


{% if salt.file.search('/etc/sudoers', '^Defaults\s+requiretty') %}
sudoers_comment_tty:
  file.comment:
    - name: /etc/sudoers
    - regex: '^Defaults\s+requiretty'
    - char: '# '
{% endif %}

sudoers_comment_wheel:
  file.comment:
    - name: /etc/sudoers
    - regex: '^\%wheel\s+ALL=\(ALL\)\s+ALL'
    - char: '# '

sudoers_uncomment_wheel_NOPASSWD:
  file.uncomment:
    - name: /etc/sudoers
    - regex: '^\%wheel\s+ALL=\(ALL\)\s+NOPASSWD:\s+ALL'
    - char: '# '
