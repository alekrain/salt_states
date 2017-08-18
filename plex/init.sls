# =============================================================================
# SaltStack State File
#
# NAME: plex/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.04.08
#
# PURPOSE: Install Plex.
#
# NOTES:
#
# EXAMPLE PILLAR:
#

{% set plex = salt.pillar.get('plex') %}

plex_install:
  pkg.installed:
    - sources:
      - plexmediaserver: https://downloads.plex.tv/plex-media-server/1.7.5.4035-313f93718/plexmediaserver-1.7.5.4035-313f93718.x86_64.rpm

{% for mount, params in plex['mounts'].iteritems() %}
plex_nfs_mount_{{ mount }}:
  mount.mounted:
    - name: {{ params.name }}
    - device: {{ params.device }}
    - fstype: {{ params.fstype }}
    - mkmnt: {{ params.mkmnt }}
    - opts: {{ params.opts }}
    - persist: {{ params.persist }}
{% endfor %}

plex_service:
  service.running:
    - name: plexmediaserver
    - enable: true
    - watch:
      - pkg: plex_install
