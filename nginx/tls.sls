# =============================================================================
# SaltStack State File
#
# NAME: nginx/nginx.sls
# VERSION: 1.0
# DATE  : 2016.02.27
#
# PURPOSE: Setup nginx
#
# CHANGE LOG:
#
# NOTES:
#

{% set nginx = salt.pillar.get('nginx') %}

{% if nginx['tls'] is defined %}
  {% if nginx['tls']['lets_encrypt'] is defined %}
nginx/init.sls - Install the private key:
  file.managed:
    - name: /etc/letsencrypt/archive/www.smartaleksolutions.com/privkey1.pem
    - contents_pillar: nginx:tls:lets_encrypt:privkey
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

nginx/init.sls - Install the full chain:
  file.managed:
    - name: /etc/letsencrypt/archive/www.smartaleksolutions.com/fullchain1.pem
    - contents_pillar: nginx:tls:lets_encrypt:fullchain
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

nginx/init.sls - Install the cert:
  file.managed:
    - name: /etc/letsencrypt/archive/www.smartaleksolutions.com/cert1.pem
    - contents_pillar: nginx:tls:lets_encrypt:cert
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

nginx/init.sls - Install the chain:
  file.managed:
    - name: /etc/letsencrypt/archive/www.smartaleksolutions.com/chain1.pem
    - contents_pillar: nginx:tls:lets_encrypt:chain
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

nginx/init.sls - Install the nginx conf for ssl:
  file.managed:
    - name: /etc/nginx/default.d/ssl.conf
    - source: salt://nginx/files/ssl.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

  {% elif nginx['tls']['self_signed'] is defined %}

nginx/init.sls - Create self signed cert:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: {{ nginx['tls']['self_signed']['tls_dir'] }}
    - bits: {{ nginx['tls']['self_signed']['bits'] }}
    - CN: {{ minion_id }}
    - C: {{ nginx['tls']['self_signed']['country'] }}
    - ST: {{ nginx['tls']['self_signed']['state'] }}
    - L: {{ nginx['tls']['self_signed']['locality'] }}
    - O: {{ nginx['tls']['self_signed']['organization'] }}
    - OU: {{ nginx['tls']['self_signed']['organizational_unit'] }}
    - emailAddress: {{ nginx['tls']['self_signed']['email'] }}
    - cacert_path: {{ nginx['tls']['self_signed']['cacert_path'] }}
    - digest: {{ nginx['tls']['self_signed']['digest'] }}
    - replace: {{ nginx['tls']['self_signed']['replace'] }}
    - unless: test -f {{ nginx['tls']['self_signed']['cacert_path'] }}/{{ nginx['tls']['self_sign']['tls_dir'] }}/certs/{{ minion_id }}.crt;
    - watch_in:
      - service: nginx/tls.sls - Start the nginx service

  {% endif %} {# if nginx['tls']['lets_encrypt'] is defined #}
{% endif %} {# if nginx['tls'] is defined #}

nginx/tls.sls - Start the nginx service:
  service.running:
    - name: nginx
    - enable: true
