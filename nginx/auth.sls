# =============================================================================
# SaltStack State File
#
# NAME: nginx/auth.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.02.27
#
# PURPOSE: Setup nginx
#
# CHANGE LOG:
#
# NOTES:
#

{% set nginx = salt.pillar.get('nginx') %}

{% if nginx['auth'] is defined %}
  {% for name, password in nginx['auth'].iteritems() %}
nginx htpasswd {{ name }}:
  webutil.user_exists:
    - htpasswd_file: /etc/nginx/htpasswd
    - name: {{ name }}
    - password: {{ password }}
    - options: m
  {% endfor %}
{% endif %}
