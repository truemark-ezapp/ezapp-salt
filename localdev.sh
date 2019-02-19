#!/usr/bin/env bash

tee /etc/rc.local <<EOF
#!/usr/bin/env bash
mkdir -p  /srv/salt && vmhgfs-fuse .host:/ezapp-salt /srv/salt -o uid=0 -o gid=0 -o umask=0027
mkdir -p  /srv/pillar && vmhgfs-fuse .host:/ezapp-pillar /srv/pillar -o uid=0 -o gid=0 -o umask=0027
mkdir -p  /srv/ext_pillar && vmhgfs-fuse .host:/ezapp-ext_pillar /srv/ext_pillar -o uid=0 -o gid=0 -o umask=0027
mkdir -p  /srv/formulas && vmhgfs-fuse .host:/ezapp-formulas /srv/formulas -o uid=0 -o gid=0 -o umask=0027
EOF
chmod +x /etc/rc.local
sleep 5
/etc/rc.local
