# =============================================================================
# SaltStack State File
#
# NAME: nagios/fcgi.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.05
#
# PURPOSE: Setup FCGI on CentOS-7
#
# NOTES:
#


nagios_fcgi_install_packages:
  pkg.installed:
    - names:
      - fcgi-devel
      - spawn-fcgi

# Install fcgiwrap from git, because CentOS does not have a package for it.
nagios_fcgi_install_fcgiwrap:
  git.latest:
    - name: https://github.com/gnosek/fcgiwrap.git
    - target: /usr/local/src/fcgiwrap
  cmd.run:
    - name: autoreconf -i && ./configure && make && make install
    - cwd: /usr/local/src/fcgiwrap
    - unless: test -x /usr/local/sbin/fcgiwrap
    - onchanges:
      - git: nagios_fcgi_install_fcgiwrap

# Setup spawn-fcgi config.
nagios_fcgi_spawn_fcgi_config:
  file.append:
    - name: /etc/sysconfig/spawn-fcgi
    - text:
      - FCGI_SOCKET=/var/run/fcgiwrap.socket
      - FCGI_PROGRAM=/usr/local/sbin/fcgiwrap
      - FCGI_USER=nginx
      - FCGI_GROUP=nginx
      - FCGI_EXTRA_OPTIONS="-M 0700"
      - OPTIONS="-u $FCGI_USER -g $FCGI_GROUP -s $FCGI_SOCKET -S $FCGI_EXTRA_OPTIONS -F 1 -P /var/run/spawn-fcgi.pid -- $FCGI_PROGRAM"

nagios_fcgi_spawn-fcgi_service:
  service.running:
    - name: spawn-fcgi
    - enable: True
    - watch:
      - pkg: nagios_fcgi_install_packages
      - git: nagios_fcgi_install_fcgiwrap
      - cmd: nagios_fcgi_install_fcgiwrap
      - file: nagios_fcgi_spawn_fcgi_config
