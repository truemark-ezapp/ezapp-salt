# This sate is responsible for setting up all formulas used throughout the remaining states
git:
  pkg.installed
# This needed to be wrapped for local development since this path is mounted
'/srv/formulas':
  file.directory:
    - user: root
    - group: root
    - mode: 750
lxd-formula:
  git.latest:
    - name: https://github.com/truemark-saltstack-formulas/lxd-formula.git
    - target: /srv/formulas/lxd-formula
    - branch: ezapp-1
pip-formula:
  git.latest:
    - name: https://github.com/truemark-saltstack-formulas/pip-formula.git
    - target: /srv/formulas/pip-formula
    - branch: ezapp-1