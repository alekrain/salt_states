# =============================================================================
# SaltStack State File
#
# NAME: celery/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.08.23
#
# PURPOSE: Setup Celery
#
# NOTES:
#   2015.07.09 - Designed to work with CentOS7
#   2017.02.23 - Required Pillar data though values can differ.
#
# EXAMPLE PILLAR:
# celery:
#   limits: |
#     celery  soft  nproc       4000
#     celery  hard  nproc       4000
#     celery  soft  nofile      4000
#     celery  hard  nofile      4000
#

celery_install:
  pip.installed:
    - name: celery

celery_install_xmltodict:
  pip.installed:
    - name: xmltodict

{% if salt.grains.get('osfinger') == 'CentOS Linux-7' %}
# Set Celery limits
celery_limits:
  file.managed:
    - name: /etc/security/limits.d/99-celery.conf
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: celery:limits
{% endif %}
