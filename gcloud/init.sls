# =============================================================================
# SaltStack State File
#
# NAME: gcloud/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2019.04.06
#
# PURPOSE: Install the gcloud repo and install the gcloud cli.
#
# CHANGE LOG:
#
# NOTES:
#
# EXAMPLE PILLAR:
# gcloud:
#   install: true
#

{{ sls }} - setup gcloud repo:
  file.managed:
    - name: /etc/yum.repos.d/google-cloud-sdk.repo
    - user: root
    - group: root
    - mode: 644
    - contents: |
        [google-cloud-sdk]
        name=Google Cloud SDK
        baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
        enabled=1
        gpgcheck=1
        repo_gpgcheck=1
        gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
               https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

{{ sls }} - install gcloud:
  pkg.installed:
    - name: google-cloud-sdk
    - require:
      - file: {{ sls }} - setup gcloud repo

{{ sls }} - install python client libraries:
  pip.installed:
    - name: google-api-python-client
