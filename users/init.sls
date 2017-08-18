#===============================================================================
# SaltStack State File
#
# NAME: users/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.05.02
#
# PURPOSE:
#   This state will read user account data from pillar and setup or modify that
#   user account to match.
#
# NOTES:
  # Example Pillar:
    # users:
    #  newuser:
    #    name: newuser
    #    fullname: New User
    #    shell: /bin/bash
    #    home: /home/newuser
    #    uid: 1000
    #    gid: 1000
    #    password: hashofsomepassword
    #    ssh_authorized_keys:
    #      key1:
    #        name: AAAAB3NzaC1...
    #        enc: ssh-rsa
    #        comment: Some_Key_Comment
    #    groups:
    #      - group1
    #      - group2
#

# Set variables from grains.
{% set hostname = salt.grains.get('id') %}

# Import user data from Pillar
{% set users = salt.pillar.get('users:users') %}

# Iterate through all users in Pillar data.
{% for user, args in users.iteritems() %}
users_{{ user }}:
  # Create group
  {% if args.gid is defined %}
  group.present:
    - gid: {{ args.gid }}
  {% else %}
  group:
    - present
  {% endif %}
    - name: {{ user }}

  # Create user
  user.present:
    - name: {{ user }}
    {% if args.fullname is defined %}
    - fullname: {{ args.fullname }}
    {% endif %}
    {% if args.shell is defined %}
    - shell: {{ args.shell }}
    {% endif %}
    {% if args.home is defined %}
    - home: {{ args.home }}
    {% endif %}
    {% if args.uid is defined %}
    - uid: {{ args.uid }}
    {% endif %}
    {% if args.gid is defined %}
    - gid: {{ args.gid }}
    {% endif %}
    {% if args.password is defined %}
    - password: {{ args.password }}
    - enforce_password: False
    {% endif %}
    - groups:
      {% if args.groups is iterable %}
      {% for group in args.groups %}
      - {{ group }}
      {% endfor %}
      {% endif %}

# Create user's home directory
users_home_dir_{{ args.home }}:
  file.directory:
    - name: {{ args.home }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 700
    - require:
      - user: {{ user }}

# If ssh keys are defined for the user, create the .ssh dir and the authorized_keys file.
{% if args.ssh_authorized_keys %}
users_ssh_dir_{{ args.home }}:
  file.directory:
    - name: {{ args.home }}/.ssh
    - user: {{ user }}
    - group: {{ user }}
    - mode: 700
    - require:
      - user: {{ user }}

{% for key, key_args in users[user]['ssh_authorized_keys'].iteritems() %}
users_authorized_keys_{{ user }}_{{ loop.index }}:
  ssh_auth.present:
    - user: {{ user }}
    {% if key_args.enc is defined %}
    - enc: {{ key_args.enc }}
    {% endif %}
    {% if key_args.name is defined %}
    - name: {{ key_args.name }}
    {% endif %}
    {% if key_args.comment is defined %}
    - comment: {{ key_args.comment }}
    {% endif %}
    - require:
      - file: {{ args.home }}/.ssh
{% endfor %}

# Make sure the SELinux context for ~/.ssh is correct.
{% if salt.grains.get('selinux') is defined  and salt.grains.get('selinux:enabled') == true %}
users_restore_selinux_context_to_home_{{ user }}:
  module.wait:
    - name: file.restorecon
    - unless: if [[ $(getenforce) == "Disabled" ]]; then exit 0; else exit 1; fi
    - onlyif: if [[ -f {{ args.home }}/.ssh/authorized_keys ]]; then exit 0; else exit 1; fi
    - path: {{ args.home }}/.ssh
    - kwargs:
        recursive: True
    - watch:
      - file: users_ssh_dir_{{ args.home }}
{% endif %} {# f salt.grains.get('selinux') is defined  and salt.grains.get('selinux:enabled') == true #}
{% endif %} {# if args.ssh_authorized_keys #}

# Add a default screenrc to all users.
users_add_screenrc_to_{{ user }}:
  file.managed:
    - name: /home/{{ user }}/.screenrc
    - source: salt://users/screenrc
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - require:
      - user: {{ user }}
    - replace: false

# Add a default gitconfig to all users.
users_add_gitconfig_to_{{ user }}:
  file.managed:
    - name: /home/{{ user }}/.gitconfig
    - source: salt://users/gitconfig
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 660
    - replace: false
    - defaults:
        hostname: {{ hostname }}
        user: {{ user }}
{% endfor %}

users_root_screenrc:
  file.managed:
    - name: /root/.screenrc
    - source: salt://users/screenrc
    - user: root
    - group: root
    - mode: 600
    - replace: false

users_root_gitconfig:
  file.managed:
    - name: /root/.gitconfig
    - source: salt://users/gitconfig
    - template: jinja
    - user: root
    - group: root
    - mode: 660
    - replace: false
    - defaults:
        hostname: {{ hostname }}
        user: root
