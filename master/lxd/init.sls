lxd.packages:
  pkg.installed:
    - pkgs:
      - zfsutils-linux
      - apparmor
      - python-pip
      - libssl-dev
      - lxd
      - lxd-client
setuptools:
  pip.installed:
    - require:
      - pkg: lxd.packages
wheel:
  pip.installed:
    - require:
      - pkg: lxd.packages
six:
  pip.installed:
    - require:
      - pkg: lxd.packages

#pylxd:
#  pip.installed:
#    - name: pylxd
#    - require:
#      - pkg: lxd.packages

{% if not salt['file.file_exists' ]('/etc/lxd-preseed.yml') %}
/etc/lxd-preseed.yml:
  file.managed:
    - source: salt://master/lxd/preseed.yml
    - user: root
    - group: root
    - mode: 640
'cat /etc/lxd-preseed.yml | lxd init --preseed':
  cmd.run
{%endif %}

{% if not salt['file.file_exists' ]('/srv/pillar/top.sls') %}
/srv/pillar/lxd/setup.sls:
  file.managed:
    - source: salt://master/lxd/setup.sls.yml
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
/srv/pillar/lxd/images.sls:
  file.managed:
    - source: salt://master/lxd/images.sls.yml
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
{%endif %}
include:
  # This includes the lxd-formula state
  - lxd
# TODO This is probably a bit too insecure and we should change how this is done
'sleep 3 && salt-key -Ay --no-color':
  cmd.run

#{#
#  Accept keys from containers if needed
##}
#{% set keys = salt['cmd.shell']('salt-key -L --out json')|load_json %}
#{% for key,val in keys.iteritems() %}
#  {% if key == 'minions_pre' %}
#    {% for cname in val  %}
#      {#%- do salt.log.error('cname:' + cname) -%#}
#      {% for container in salt['pillar.get']('lxd:containers:local', {}).iteritems() %}
#        {#%- do salt.log.error('container:' + container[0]) -%#}
#        {% if cname == container[0] + '.lxd' %}
#          {#%- do salt.log.error('moo:' + cname) -%#}
#'salt-key -Ay --no-color {{ cname }}':
#  cmd.run:
#    - require:
#      - lxd
#'sleep 10 && salt {{ cname }} state.apply':
#  cmd.run:
#    - bg: True
#        {% endif %}
#      {% endfor %}
#    {% endfor %}
#  {% endif %}
#{% endfor %}



