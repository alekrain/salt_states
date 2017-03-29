***Nagios State***
---
This SaltStack state is built to install and configure Nagios on CentOS-7 with what I think are sane defaults. The underlying stack is Nginx, spawn-fcgi, and php-fpm. It will install and configure those components as well.

It is a little involved. It has a requirement for the rather lengthy bit of Pillar data displayed at the top of the init.sls. If you want to have a look through there and replace the ALL CAPS entries, you can run local by just removing the jinja comment around that entire block.

*Pushover Alerts*
---
I really like pushover when it comes to receiving alerts, so I've made a couple of includes that set it up it in this state. If you don't have or want to use pushover, set the pushover section to False in the pillar data. This also removes the requirement for python3.
```
nagios:
  use_pushover: False
```
Note that you will still need to edit the contact definitions appropriately under `nagios:confd:custom_contacts`. And, unless you define a new contact type on which to base your contacts, you'll want to use the 'generic-contact'.
```
custom_contacts:
  USER1:
    contact_name: USER1
    use: generic-contact
    contactgroups: admins
    email: USER1@LOCALHOST
```
If you do want pushover though, you will need my 'pushover' and 'python3' states as well. You can setup different pushover keys per user as in the example data, or as a group by filling in the `address1` and `address2` keys for the contact type like below.
```
nagios:
  confd:
    ...
    custom_contacts:
      basic-contact:
        name: basic-contact
        use: generic-contact
        service_notification_options: u,c
        host_notification_options: d,u
        service_notification_commands: notify-service-by-pushover
        host_notification_commands: notify-host-by-pushover
        address1: PUSHOVER_GROUP_KEY_GOES_HERE
        address2: PUSHOVER_APP_TOKEN_GOES_HERE
        register: 0
```
*Host Addresses*
---
The last requirement is for a salt mine function. For the `node.jinja` template to render the `address` entry correctly, you must have a mine function for `network.ip_addrs` running for all hosts that you want to define in nagios. If you do not, `address` will not render at all. It won't break, but if DNS does not resolve to your hosts you will have issues. My salt mine definitions live in a different pillar, but it looks like this:
```
{%- if salt.match.ipcidr('10.0.0.0/8') %}
  {%- set cidr = '10.0.0.0/8' %}
{%- elif salt.match.ipcidr('172.16.0.0/12') %}
  {%- set cidr = '172.16.0.0/12' %}
{%- elif salt.match.ipcidr('192.168.0.0/16') %}
    {%- set cidr = '192.168.0.0/16' %}
{%- endif %}

mine_interval: 60
mine_functions:
  network.ip_addrs:
    cidr: {{ cidr }}
```
