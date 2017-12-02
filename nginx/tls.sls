# =============================================================================
# SaltStack State File
#
# NAME: nginx/tls.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE: 2017.12.02
#
# PURPOSE: Setup TLS for Nginx
#
# EXAMPLE PILLAR:
#
# nginx:
#   tls:
#     email: noc@smartaleksolutions.com
#     certbot:
#       listen: 443 ssl
#       fqdn: salt.smartaleksolutions.com
#     self:
#       listen: 443 ssl
#       tls_dir: tls
#       bits: 2048
#       country: US
#       state: GA
#       locality: Woodsticks
#       organization: SmartAlek Solutions
#       organizational_unit: DevOps
#       cacert_path: /etc/pki
#       digest: sha256
#       replace: false


{% set nginx = salt.pillar.get('nginx') %}

{% if nginx['tls'] is defined %}
nginx/tls.sls - Install nginx ssl modules:
  pkg.installed:
    - name: mod_ssl

nginx/tls.sls - Install pyopenssl:
  pip.installed:
    - name: pyopenssl
    - bin_env: /bin/pip2
    - reload_modules: True

  {%- if nginx['tls']['certbot'] is defined %}
nginx/tls.sls - install certbot:
  pkg.installed:
    - name: python2-certbot-nginx

nginx/tls.sls - execute certbot:
  cmd.wait:
    - name: /bin/certbot --nginx certonly --non-interactive --agree-tos --no-self-upgrade --email {{ nginx.tls.email }}
    - unless: test -d /etc/letsencrypt/archive
    - watch:
      - pkg: nginx/tls.sls - install certbot

nginx/tls.sls - setup crontab for renewal:
  cron.present:
    - user: root
    - identifier: certbot_update_tls_cert
    - coment: Update TLS Cert with Certbot
    - name: /bin/certbot renew
    - minute: 0
    - hour: 16
    - daymonth: 15

  {% elif nginx['tls']['self'] is defined %}
nginx/init.sls - Create self signed cert:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: {{ nginx['tls']['self']['tls_dir'] }}
    - bits: {{ nginx['tls']['self']['bits'] }}
    - CN: {{ minion_id }}
    - C: {{ nginx['tls']['self']['country'] }}
    - ST: {{ nginx['tls']['self']['state'] }}
    - L: {{ nginx['tls']['self']['locality'] }}
    - O: {{ nginx['tls']['self']['organization'] }}
    - OU: {{ nginx['tls']['self']['organizational_unit'] }}
    - emailAddress: {{ nginx['tls']['email'] }}
    - cacert_path: {{ nginx['tls']['self']['cacert_path'] }}
    - digest: {{ nginx['tls']['self']['digest'] }}
    - replace: {{ nginx['tls']['self']['replace'] }}
    - unless: test -f {{ nginx['tls']['self']['cacert_path'] }}/{{ nginx['tls']['self_sign']['tls_dir'] }}/certs/{{ minion_id }}.crt;
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

  {% endif %} {# if nginx['tls']['certbot'] is defined #}

nginx/init.sls - Install the nginx conf for tls:
  file.managed:
    - name: /etc/nginx/default.d/ssl.conf
    - source: salt://nginx/files/ssl.conf
    - template: jinja
    - defaults:
        tls: {{ nginx.tls }}
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

{% endif %} {# if nginx['tls'] is defined #}

nginx/tls.sls - Start the nginx service:
  service.running:
    - name: nginx
    - enable: true
