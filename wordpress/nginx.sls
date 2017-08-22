# =============================================================================
# SaltStack State File
#
# NAME: wordpress/nginx.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.19
#
# PURPOSE: Setup Wordpress with Nginx
#
# NOTES:
#


{% set wordpress = salt.pillar.get('wordpress') %}
{% set minion_id = salt.grains.get('id') %}

wordpress_install_packages:
  pkg.installed:
    - names:
      - nginx
      - httpd-tools

wordpress_nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://wordpress/files/nginx.conf.jinja
    - template: jinja
    - user: nginx
    - group: nginx
    - mode: 644
    - defaults:
        wordpress: {{ wordpress }}

{% if wordpress['tls']['setup_tls'] == true %}
  {% if wordpress['tls']['lets_encrypt']['install'] == true %}
wordpress_nginx_install_certbot:
  pkg.installed:
    - name: python2-certbot-nginx

wordpress_nginx_certbot_cert:
  file.managed:
    - name: /etc/letsencrypt/live/{{ wordpress.common_name }}/fullchain.pem
    - contents_pillar: wordpress:tls:lets_encrypt:cert
  module.run:
    - name: event.fire_master
    - tag: salt/alert/{{ minion_id }}/wordpress
    - data: Change in SSL cert for {{ minion_id }}
    - onchanges:
      - file: wordpress_nginx_certbot_cert

  {% else %}

wordpress_nginx_install_pyopenssl:
  pip.installed:
    - name: pyopenssl
    - bin_env: /bin/pip2
    - reload_modules: True

wordpress_nginx_tls:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: {{ wordpress['tls']['self_sign']['tls_dir'] }}
    - bits: {{ wordpress['tls']['self_sign']['bits'] }}
    - CN: {{ minion_id }}
    - C: {{ wordpress['tls']['self_sign']['country'] }}
    - ST: {{ wordpress['tls']['self_sign']['state'] }}
    - L: {{ wordpress['tls']['self_sign']['locality'] }}
    - O: {{ wordpress['tls']['self_sign']['organization'] }}
    - OU: {{ wordpress['tls']['self_sign']['organizational_unit'] }}
    - emailAddress: {{ wordpress['tls']['self_sign']['email'] }}
    - cacert_path: {{ wordpress['tls']['self_sign']['cacert_path'] }}
    - digest: {{ wordpress['tls']['self_sign']['digest'] }}
    - replace: {{ wordpress['tls']['self_sign']['replace'] }}
    - unless: test -f {{ wordpress['tls']['self_sign']['cacert_path'] }}/{{ wordpress['tls']['self_sign']['tls_dir'] }}/certs/{{ minion_id }}.crt;
  {% endif %}{# if wordpress['tls']['cert'] is defined #}
{% endif %}{# if wordpress['tls']['setup_tls'] == true #}

{% for name, password in wordpress['auth'].iteritems() %}
wordpress_nginx_htpasswd_{{ name }}:
  webutil.user_exists:
    - htpasswd_file: /etc/nginx/htpasswd
    - name: {{ name }}
    - password: {{ password }}
    - options: m
{% endfor %}

wordpress_nginx_service:
  service.running:
    - name: nginx
    - reload: true
    - enable: true
    - watch:
      - file: wordpress_nginx_config
