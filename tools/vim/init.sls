vim:
  pkg.installed
/etc/vim/vimrc.local:
  file.managed:
    - source: salt://tools/vim/vimrc.local
    - user: root
    - group: root
    - mode: 644