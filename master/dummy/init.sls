# This state is responsible for setting up the dummy interface on the salt master
/etc/systemd/system/dummy.service:
  file.managed:
    - source: salt://master/dummy/dummy.service
    - user: root
    - group: root
    - mode: 644
{% set ifaces = grains['ip_interfaces'].keys() %}
{% if 'dummy0' not in ifaces %}
'systemctl daemon-reload':
  cmd.run
'systemctl enable dummy.service':
  cmd.run
'systemctl start dummy':
  cmd.run
'refresh grains':
  module.run:
    - name: saltutil.refresh_grains
    - reload_grains: true
{% endif %}
169.254.1.1:
  host.only:
    - hostnames:
        - salt
127.0.0.1:
  host.only:
    - hostnames:
      - localhost
