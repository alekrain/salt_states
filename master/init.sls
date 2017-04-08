# =============================================================================
# SaltStack State File
#
# NAME: master/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2016.09.16
#
# PURPOSE: Install the salt master and its config files.
#
# NOTES:
#
# EXAMPLE PILLAR:
  # master:
  #   install: True
  #   id: salt.smartaleksolutions.com
  #   master:
  #     conf: |
  #       # Managed by Salt
  #       file_roots:
  #         base:
  #           - /srv/salt
  #       pillar_roots:
  #         base:
  #           - /srv/pillar
  #       log_file: /var/log/salt/master
  #       log_level: debug
  #   reactor:
  #     conf: |
  #       # Managed by Salt
  #       reactor:
  #         - 'salt/beacon/*/*/nagios':
  #           - /srv/salt/_reactors/nagios_forward_event.sls
  #         - 'salt/alert/*/*':
  #           - /srv/salt/_reactors/pushover.sls
  #     reactors:
  #       nagios_forward_event:
  #         nagios_minion_id: nagios.smartaleksolutions.com
  #       pushover:
  #         pushover_app_token: YOUR_PUSHOVER_TOKEN
  #         pushover_user_key: YOUR_PUSHOVER_USER_KEY
  #   salt_api:
  #     conf: |
  #       # Managed by Salt
  #       rest_cherrypy:
  #         port: 8000
  #         ssl_crt: /etc/pki/tls/certs/localhost.crt
  #         ssl_key: /etc/pki/tls/certs/localhost.key
  #         debug: True

{% set master = salt.pillar.get('master') %}

{% if master.master.conf is defined %}
master_master_packages:
  pkg.installed:
    - names:
      - salt-master

master_master_conf:
  file.managed:
    - name: /etc/salt/master
    - contents_pillar: master:master:conf
    - user: root
    - group: root
    - mode: 600
{% endif %} {# if master.master.conf is defined #}

{% if master.reactor.conf is defined %}
master_reactor_conf:
  file.managed:
    - name: /etc/salt/master.d/reactor.conf
    - contents_pillar: master:reactor:conf
    - user: root
    - group: root
    - mode: 600
{% endif %} {# if master.reactor.conf is defined #}

{% for reactor, params in master['reactor']['reactors'].iteritems() %}
master_reactors_{{ reactor }}:
  file.managed:
    - name: /srv/salt/_reactors/{{ reactor }}.sls
    - source: salt://_reactors/{{ reactor }}.jinja
    - template: jinja
    - defaults:
        params: {{ params }}
    - user: root
    - group: root
    - mode: 600
{% endfor %} {# for reactor in master.reactor.reactors #}

{% if master.salt_api.conf is defined %}
master_saltapi_packages:
  pkg.installed:
    - names:
      - python2-pip
      - python-devel
      - libffi-devel
      - openssl-devel
      - salt-api

master_saltapi_pip_cherrypy:
  pip.installed:
    - name: CherryPy

master_saltapi_pip_pyopenssl:
  pip.installed:
    - name: pyOpenSSL
    - reload_modules: true

master_saltapi_keys:
  module.run:
    - name: tls.create_self_signed_cert
    - unless: if [[ -f /etc/pki/tls/certs/localhost.crt ]]; then exit 0; else exit 1; fi

master_saltapi_conf:
  file.managed:
    - name: /etc/salt/master.d/salt-api.conf
    - contents_pillar: master:salt_api:conf
    - user: root
    - group: root
    - mode: 600

master_saltapi_restart:
  service.running:
    - name: salt-api
    - enable: True
    - watch:
      - service: master_master_restart
{% endif %} {# if master.salt_api.conf is defined #}

{% if master.cloud is defined %}
master_cloud_packages:
  pkg.installed:
    - name: salt-cloud

{% for provider in master.cloud.providers %}
master_cloud_providers_{{ provider }}:
  file.managed:
    - name: /etc/salt/cloud.providers.d/{{ provider }}.conf
    - contents_pillar: master:cloud:providers:{{ provider }}
    - user: root
    - group: root
    - mode: 600
{% endfor %} {# for provider in master.cloud.providers #}

{% for profile in master.cloud.profiles %}
master_cloud_profiles_{{ profile }}:
  file.managed:
    - name: /etc/salt/cloud.profiles.d/{{ profile }}.conf
    - contents_pillar: master:cloud:profiles:{{ profile }}
    - user: root
    - group: root
    - mode: 600
{% endfor %} {# for profile in master.cloud.profiles #}
{% endif %} {# if master.cloud is defined #}

master_update_engines:
  module.run:
    - name: saltutil.sync_engines

master_master_restart:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: master_master_conf
      - file: master_reactor_conf
      - file: master_saltapi_conf
