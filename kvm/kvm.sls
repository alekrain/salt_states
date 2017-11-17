#===============================================================================
# SaltStack State File
#
# NAME: kvm/kvm.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2015.10.06
#
# PURPOSE: Setup KVM/Libvirt as much as possible without network configs.
#
# NOTES:
#


{# Set the threshold or leave it at the default of 20% #}
{% set ksm = salt.pillar.get('kvm:ksm', {}) %}

# Add necessary Repo
kvm_repo:
  file.managed:
    - name: /etc/yum.repos.d/qemu-kvm-rhev.repo
    - source: salt://kvm/files/qemu-kvm-rhev.repo
    - user: root
    - group: root
    - mode: 644

# Install necessary packages
kvm_packages:
  pkg.installed:
    - names:
      - bridge-utils
      - libguestfs-tools
      - libvirt
      - libvirt-python
      - qemu
      - qemu-kvm-ev
      - qemu-guest-agent
      - psmisc
      - ngrep
  require:
    - file: kvm_repo

# Create a symlink to the qemu-kvm binary
kvm_qemu-kvm_symlink:
  file.symlink:
    - name: /usr/bin/qemu-kvm
    - target: /usr/libexec/qemu-kvm
  require:
    - pkg: kvm_packages

# Set KSM threshold coefficient
kvm_ksm_set_threshold_coefficient:
  file.managed:
    - name: /etc/ksmtuned.conf
    - source: salt://kvm/files/ksmtuned.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        ksm: {{ ksm }}
  require:
    - pkg: kvm_packages

# Enable and start ksmd
kvm_start_ksm:
  service.running:
    - name: ksm
    - enable: True
    - sig: ksmd
    - init_delay: 5
    - watch:
      - file: kvm_ksm_set_threshold_coefficient
  require:
    - pkg: kvm_packages
    - service: kvm_start_libvirtd

# Disable and stop the NetworkManager service as it will interfere with bridging.
kvm_NetworkManager_service:
  service.dead:
    - name: NetworkManager
    - enable: False

# Enable IP Forwarding
kvm_ipv4_ip_forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
  require:
    - pkg: kvm_packages

# Force all traffic through IP tables on the host. Though the default value is already 1,
# it is set here just to be explicit.
kvm_bridge_bridge-nf-call-iptables:
  sysctl.present:
    - name: net.bridge.bridge-nf-call-iptables
    - value: 1
  require:
    - pkg: kvm_packages

# Enable and start the libvirt daemon
kvm_libvirt_service:
  service.running:
    - name: libvirtd
    - enable: True
  require:
    - pkg: kvm_packages
    - service: kvm_NetworkManager_service
    - sysctl: kvm_ipv4_ip_forward
    - sysctl: kvm_bridge_bridge-nf-call-iptables
