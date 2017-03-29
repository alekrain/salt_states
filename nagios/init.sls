# =============================================================================
# SaltStack State File
#
# NAME: nagios/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.05
#
# PURPOSE: Setup Nagios with Nginx, PHP, and FCGI on CentOS-7
#
# NOTES:
#   Example Pillar:


{#
{% load_yaml as nagios_load %}
nagios:
  use_pushover: True
  tls:
    setup_tls: True
    tls_dir: tls
    bits: 2048
    common_name: NAGIOS.MYDOMAIN.COM
    country: US
    state: Georgia
    locality: Atlanta
    organization: MYCOMPANY
    organizational_unit: None
    email: ROOT@LOCALHOST
    cacert_path: /etc/pki
    digest: sha256
    replace: False
  auth:
    nagiosadmin: nagiosadmin
  cfg:
    service_check_timeout: 90
    host_check_timeout: 30
    process_performance_data: 0
  confd:
    custom_commands:
      notify-service-by-pushover: '/bin/python3 /usr/local/libexec/pushover.py -user $CONTACTADDRESS1$ -token $CONTACTADDRESS2$ -title "$HOSTNAME$" -message "State: $SERVICESTATE$ - $SERVICEDESC$ - $NOTIFICATIONCOMMENT$"'
      notify-host-by-pushover: '/bin/python3 /usr/local/libexec/pushover.py -user $CONTACTADDRESS1$ -token $CONTACTADDRESS2$ -title "$HOSTNAME$" -message "State: $HOSTSTATE$ for $HOSTDURATION$ - $NOTIFICATIONCOMMENT$"'
      check_dummy: '$USER1$/check_dummy 2 "NO DATA RECEIVED"'
      check_nrpe: '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$'
      check_nrpe_extended_timeout: '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 60 -c $ARG1$'
    custom_contacts:
      basic-contact:
        name: basic-contact
        use: generic-contact
        service_notification_options: u,c
        host_notification_options: d,u
        service_notification_commands: notify-service-by-pushover
        host_notification_commands: notify-host-by-pushover
        register: 0
      USER1:
        contact_name: USER1
        use: basic-contact
        contactgroups: admins
        email: USER1@LOCALHOST
        address1: PUSHOVER_USER_KEY_GOES_HERE
        address2: PUSHOVER_APP_TOKEN_GOES_HERE
    custom_hostgroups:
      centos7-servers:
        alias: CentOS-7 Servers
        services:
          PING:
            use: active-service
            check_command: check_ping!100.0,20%!500.0,60%
          SSH:
            use: active-service
            check_command: check_ssh
          Root Partition:
            use: active-service
            check_command: check_nrpe!check_root
          Current Users:
            use: active-service
            check_command: check_nrpe!check_users
          Total Processes:
            use: active-service
            check_command: check_nrpe!check_total_procs
          Current Load:
            use: active-service
            check_command: check_nrpe!check_load
          Swap Usage:
            use: active-service
            check_command: check_nrpe!check_swap
    custom_hosts:
      centos7-server:
        use: linux-server
        notification_period: 24x7
        notification_interval: 60
        notification_options: d,u
        statusmap_image: centos40.gd2
        vrml_image: centos40.png
        icon_image: centos40a.png
        icon_image_alt: CentOS-7
        contact_groups: admins
        register: 0
      ubuntu1604-server:
        use: linux-server
        notification_period: 24x7
        notification_interval: 60
        notification_options: d,u
        statusmap_image: ubuntu40.gd2
        vrml_image: ubuntu40.png
        icon_image: ubuntu40a.png
        icon_image_alt: Ubuntu 16.04
        contact_groups: admins
        register: 0
    custom_services:
      active-service:
        use: generic-service
        passive_checks_enabled: 0
        register: 0
      passive-service:
        use: generic-service
        active_checks_enabled: 0
        check_freshness: 1
        freshness_threshold: 300
        check_command: check_dummy
        register: 0
  equipment:
    servers:
      SERVER1:
        use: centos7-server
        alias: SERVER1
        hostgroups: centos7-servers
      SERVER2:
        use: centos7-server
        alias: SERVER2
        hostgroups: centos7-servers
        services:
          Uptime:
            use: active-service
            service_description: Uptime
            check_command: check_nrpe!check_uptime
          OS Version:
            use: active-service
            service_description: OS Version
            check_command: check_nrpe!check_version
{% endload %}
{% set nagios = nagios_load.nagios %}
#}


{% if nagios is not defined %}
{% set nagios = salt.pillar.get('nagios') %}
{% endif %}

include:
  - ./fcgi
  - ./php_fpm
  - ./nginx
  - ./nagios
{% if nagios['use_pushover'] == true %}
  - python3
  - pushover
{% endif %}
