{% for host, ip in salt.pillar.get('hostsfile:entries').iteritems() %}
test_{{ host }}_{{ ip }}:
  file.append:
    - name: /tmp/test.txt
    - text: {{ host }}  {{ ip }}
{% endfor %}
