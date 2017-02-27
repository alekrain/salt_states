# =============================================================================
# SaltStack State File
#
# NAME: gitrepos/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.11.03
#
# PURPOSE: install from our git repositories
#
# NOTES:
#
# EXAMPLE PILLAR:
# gitrepos:
#   beacons:
#     remote_path: https://github.com/alektant/salt_beacons.git
#     local_path: /srv/salt/_beacons
#     revision: cd2365b7174becae78c7d5586eef92c370796e7b # optional
#     user: root

{% set repos = salt.pillar.get('gitrepos') %}

gitrepos_install_packages:
  pkg.installed:
    - name: git

{% for repo, params in repos.iteritems() %}
gitrepos_{{ repo }}:
  git.latest:
    - name: {{ params.remote_path }}
{% if params.revision is defined %}
    - rev: {{ params.revision }}
{% endif %} {# repo.revision #}
    - target: {{ params.local_path }}
    - user: {{ params.user }}
    - update_head: False
    - require:
      - pkg: gitrepos_install_packages
{% endfor %}
