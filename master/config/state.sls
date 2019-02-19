# This state is responsible for setting up the top.sls file for states
/srv/salt/top.sls:
  file.managed:
    - source: salt://master/config/state_top.sls.yml
    - mode: keep
    - template: jinja