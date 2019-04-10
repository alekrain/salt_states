#===============================================================================
# SaltStack State File
#
# NAME: {{ sls }}
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.06.18
#
# PURPOSE: Create gcp_fru (GCP Firewall Rules Updater) user.
#
# NOTES:

{{ sls }} - create user gcp-fru:
  file.directory:
    - name: /opt/smrt/
    - user: root
    - group: root
    - mode: 775
    - makedirs: true
  group.present:
    - gid: 1903
    - name: gcp-fru
  user.present:
    - name: gcp-fru
    - fullname: gcp firewall rules updater
    - shell: /bin/bash
    - home: /opt/smrt/gcp-fru
    - createhome: true
    - uid: 1903
    - gid: 1903
    - password: $6$BgG4EufG$qXhPlSxj8Db5Qi70Zu10abgbB5xtdnsuSrUKlK8KNtAUnzEO/9Ga02pnoXgp7OtLPrD5rSO/BYOctmthAHa84n/
