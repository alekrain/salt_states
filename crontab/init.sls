#===============================================================================
# SaltStack State File
#
# NAME: cron/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.04.08
#
# PURPOSE: Install cron jobs from pillar.
#
# NOTES:
#   Pillar should look like:
#     crontab:
#       user:
#         task:
#           identifier: salt_identifier
#           comment:  some_comment
#           name:  to_perform
#           special: optional [@reboot, @daily, @hourly, ...]
#           minute: optional minute, default is '*'
#           hour: optional hour, default is '*'
#           daymonth: optional day of month, default is '*'
#           month: optional month, default is '*'
#           dayweek: optional day week, default is '*'
#

{%- set crontab = salt.pillar.get('crontab') %}

{%- for user, tasks in crontab.iteritems() %}
crontab_add_header:
  cron.env_present:
    - name: PATH
    - user: {{ user }}
    - value: "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

{%- for task, params in tasks.iteritems() %}
crontab_{{ user }}_{{ task }}:
  cron.present:
    - user: {{ user }}
    - identifier: {{ params.identifier }}
    - comment: {{ params.comment }}
    - name: {{ params.name }}
    {% if params.special is defined -%}
    - special: '{{ params.special }}'
    {% endif -%}
    {% if params.minute is defined -%}
    - minute: '{{ params.minute }}'
    {% endif -%}
    {% if params.hour is defined -%}
    - hour: '{{ params.hour }}'
    {% endif -%}
    {% if params.daymonth is defined -%}
    - daymonth: '{{ params.daymonth }}'
    {% endif -%}
    {% if params.month is defined -%}
    - month: '{{ params.month }}'
    {% endif -%}
    {% if params.dayweek is defined -%}
    - dayweek: '{{ params.dayweek }}'
    {% endif -%}
{% endfor -%}
{% endfor -%}
