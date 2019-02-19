# This state is responsible for setting up the top.sls file for pillar data
/srv/pillar:
  file.directory:
    - makedirs: true
/srv/ext_pillar/hosts:
  file.directory:
    - makedirs: true
/srv/pillar/top.sls:
  file.managed:
    - source: salt://master/config/pillar_top.sls.yml
    - mode: keep
    - template: jinja
# Since the top.sls file contains a reference to LXD, we have to create an empty placeholder
/srv/pillar/lxd:
  file.directory:
    - makedirs: true
'touch /srv/pillar/lxd/empty.sls':
  cmd.run:
    - unless: ls /srv/pillar/lxd/empty.sls
saltutil.refresh_pillar:
  module.run