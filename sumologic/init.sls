#===============================================================================
# SaltStack State File
#
# NAME: sumologic/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.11.26
#
# PURPOSE: Setup sumologic collector
#
# EXAMPLE PILLAR:
#   sumologic:
#     install: true
#     user:
#       accessid: api id to use to register and send data to sumo. Generate on their website.
#       accesskey: api key to use to register and send data to sumo. Generate on their website.
#       name: name of the collector. This can and will usually be the name of the host.
#       hostName: set in pillar, or the state will use the value of the 'name' key from above.
#       syncSources: (optional) key that points to a json file with the sources configuation.
#       timeZone: (optional) America/New_York or use another from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
#       category: (optional) default source category to use when source does not specify.
#       description: (optional) description to show in sumologic for this collector.
#

{% from "sumologic/user_vars.jinja" import sumologic with context %}

sumologic/init.sls - install sumocollector:
  pkg.installed:
    - sources:
      - SumoCollector: salt://sumologic/files/SumoCollector-19.209-8.x86_64.rpm

sumologic/init.sls - setup the user.properties file:
  file.managed:
    - name: /opt/SumoCollector/config/user.properties
    - source: salt://sumologic/files/user.properties.jinja
    - template: jinja
    - defaults:
        user: {{ sumologic['user'] }}
    - mode: 640
    - user: root
    - group: sumologic_collector

sumologic/init.sls - (re)start the collector service:
  service.running:
    - name: collector
    - enable: true
    - watch:
      - file: sumologic/init.sls - setup the user.properties file
