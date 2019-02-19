# This state is responsible for configuring the salt-master daemon
# This needed to be wrapped for local development since this path is mounted
/etc/salt/master.d/file_roots.conf:
  file.managed:
    - source: salt://master/config/file_roots.conf.yml
    - user: root
    - group: root
    - mode: 644
/etc/salt/master.d/ext_pillar.conf:
  file.managed:
    - source: salt://master/config/ext_pillar.conf.yml
    - user: root
    - group: root
    - mode: 644
'restart salt master':
  cmd.run:
    - name: 'salt-call service.restart salt-master && salt \* saltutil.sync_modules && salt \* saltutil.sync_states'
    - bg: True
    - onchanges:
      - file: /etc/salt/master.d/file_roots.conf
      - file: /etc/salt/master.d/ext_pillar.conf