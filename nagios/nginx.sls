# =============================================================================
# SaltStack State File
#
# NAME: nagios/nginx.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.05
#
# PURPOSE: Setup Nginx on CentOS-7
#
# NOTES:
#

{% from 'nagios/init.sls' import nagios with context %}

# Install necessary packages
nagios_nginx_install_packages:
  pkg.installed:
    - names:
      - nginx

# Install the nginx config and setup TLS.
nagios_nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nagios/nginx.jinja
    - template: jinja
    - user: nginx
    - group: nginx
    - mode: 664
    - defaults:
        nagios: {{ nagios }}
        hostname: {{ salt.grains.get('id') }}

{% if nagios['tls']['setup_tls'] == true %}
nagios_nginx_install_pyopenssl:
  pip.installed:
    - name: pyopenssl
    - bin_env: /bin/pip2
    - reload_modules: True

nagios_nginx_tls:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: {{ nagios['tls']['tls_dir'] }}
    - bits: {{ nagios['tls']['bits'] }}
    - CN: {{ nagios['tls']['common_name'] }}
    - C: {{ nagios['tls']['country'] }}
    - ST: {{ nagios['tls']['state'] }}
    - L: {{ nagios['tls']['locality'] }}
    - O: {{ nagios['tls']['organization'] }}
    - OU: {{ nagios['tls']['organizational_unit'] }}
    - emailAddress: {{ nagios['tls']['email'] }}
    - cacert_path: {{ nagios['tls']['cacert_path'] }}
    - digest: {{ nagios['tls']['digest'] }}
    - replace: {{ nagios['tls']['replace'] }}
    - unless: test -f {{ nagios['tls']['cacert_path'] }}/{{ nagios['tls']['tls_dir'] }}/certs/{{ nagios['tls']['common_name'] }}.crt;
{% endif %}

{% for name, password in nagios['auth'].iteritems() %}
nagios_nginx_htpasswd_{{ name }}:
  webutil.user_exists:
    - htpasswd_file: /etc/nginx/htpasswd
    - name: {{ name }}
    - password: {{ password }}
    - options: m
{% endfor %}

nagios_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nagios_nginx_install_packages
      - file: nagios_nginx_config
