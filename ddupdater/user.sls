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
  group.present:
    - gid: 1902
    - name: ddupdater
  user.present:
    - name: ddupdater
    - fullname: ddupdater
    - shell: /bin/bash
    - home: /opt/smrt/ddupdater
    - uid: 1902
    - gid: 1902
    - password: $6$BgG4EufG$qXhPlSxKA7M7Ii70Zu10abgbB5xtdnsuSrUKlK8KNtAUnzEO/9Ga02pnoXgp7OtLPrD5rSO/BYOctmthAHa84n/
  file.directory:
    - name: /opt/smrt/ddupdater
    - user: ddupdater
    - group: ddupdater
    - mode: 700
    - require:
      - user: {{ sls }} - create user ddupdater
