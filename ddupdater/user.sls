#===============================================================================
# SaltStack State File
#
# NAME: {{ sls }}
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.06.18
#
# PURPOSE: Create ddupater user.
#
# NOTES:

{{ sls }} - create user ddupdater:
  file.directory:
    - name: /opt/smrt/
    - user: root
    - group: root
    - mode: 775
    - makedirs: true
  group.present:
    - gid: 1902
    - name: ddupdater
  user.present:
    - name: ddupdater
    - fullname: ddupdater
    - shell: /bin/bash
    - home: /opt/smrt/ddupdater
    - createhome: true
    - uid: 1902
    - gid: 1902
    - password: $6$BgG4EufG$qXhPlSxKA7M7Ii70Zu10abgbB5xtdnsuSrUKlK8KNtAUnzEO/9Ga02pnoXgp7OtLPrD5rSO/BYOctmthAHa84n/
