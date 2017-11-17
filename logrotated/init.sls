# =============================================================================
# SaltStack State File
#
# NAME: logrotated/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.03.24
#
# NOTES: Installs config files needed for log rotation by the logrotated daemon.
#
# EXAMPLE PILLAR:
# logrotated:
#   install: true
#   logs:
#     rclone:
#       archive_dir: /var/log/rclone
#       user: root
#       group: root
#       conf: |
#         /var/log/rclone/rclone.log {
#                 daily
#                 missingok
#                 rotate 7
#                 compress
#                 notifempty
#         }


{% set logrotated = salt.pillar.get('logrotated') %}
{% for log, params in logrotated.logs.iteritems() %}

logrotated/init.sls - create archive directory for {{ log }}:
  file.directory:
    - name: {{ params.archive_dir }}
    - user: {{ params.user }}
    - group: {{ params.group }}
    - makedirs: True
    - dir_mode: 755
    - file_mode: 644
    - recurse:
        - user
        - group
        - mode

logrotated/init.sls - create config for {{ log }}:
  file.managed:
    - name: /etc/logrotate.d/{{ log }}
    - contents_pillar: logrotated:logs:{{ log }}:conf
    - mode: 644
    - user: root
    - group: root
{% endfor %}
