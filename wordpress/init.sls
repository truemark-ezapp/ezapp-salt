wordpress.packages:
  pkg.installed:
    - pkgs:
      - php-curl
      - php-soap
      - php-mbstring
      - php-mysql
      - php-xml
      - php-gd
      - php-cli
      - php-ssh2
      - php-fpm
      - nginx
      - postfix
      - mariadb-server
      - wget
      - python-mysqldb

# Install wpcli
'/usr/local/bin/wp':
  file.managed:
    - source: https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755
'/home/wordpress/.wp-cli/config.yml':
  file.managed:
    - source: salt://wordpress/wp-cli.yml
    - user: root
    - group: root
    - mode: 644
    - template: jinja

# Setup user and group for the site
wordpress:
  group.present:
    - gid: 2000
    - system: False
  user.present:
    - fullname: WordPress
    - shell: /bin/bash
    - home: /home/wordpress
    - uid: 2000
    - gid: 2000

# Setup PHP FPM
'/etc/php/7.2/fpm/pool.d/www.conf':
  file.managed:
    - source: salt://wordpress/fpm-www.conf
    - user: root
    - group: root
    - mode: 644

'restart php fpm':
  cmd.run:
    - name: service php7.2-fpm restart
    - onchanges:
      - file: /etc/php/7.2/fpm/pool.d/www.conf

# Manage SSL Certs
'/etc/nginx/ssl':
  file.directory:
    - user: root
    - group: root
    - mode: 755

{% if not salt['file.file_exists']('/etc/nginx/ssl/server.crt') %}
'gen_ssl_key':
  cmd.run:
    - name: openssl genrsa -out server.key 2048
    - cwd: /etc/nginx/ssl
'gen_ssl_csr':
  cmd.run:
    - name: openssl req -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/C=US/ST=Utah/L=Salt Lake City/O=Global Security/OU=IT Department/CN={{ pillar['wordpress']['server_name'].split()[0] }}"
    - cwd: /etc/nginx/ssl
'gen_ssl_crt':
  cmd.run:
    - name: openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
    - cwd: /etc/nginx/ssl
{% endif %}

'/etc/nginx/ssl/server.key':
  file.managed:
    - user: root
    - group: root
    - mode: 600

# Setup Nginx
'/etc/nginx/sites-available/default':
  file.managed:
    - source: salt://wordpress/nginx-default.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

'/etc/nginx/wprestrictions.conf':
  file.managed:
    - source: salt://wordpress/nginx-wprestrictions.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

'/etc/nginx/wordpress.conf':
  file.managed:
    - source: salt://wordpress/nginx-wordpress.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

'restart nginx':
  cmd.run:
    - name: service nginx restart
    - onchanges_any:
      - file: /etc/nginx/sites-available/default
      - file: /etc/nginx/wprestrictions.conf
      - file: /etc/nginx/wordpress.conf

# Setup database
'create_database':
  mysql_database.present:
    - name: {{ pillar['wordpress']['db_name'] }}
    - character_set: utf8
    - collate: utf8_general_ci
'create_database_user':
  mysql_user.present:
    - host: localhost
    - name: {{ pillar['wordpress']['db_user'] }}
    - password: "{{ pillar['wordpress']['db_pass'] }}"
'grant user':
  mysql_grants.present:
    - grant: all privileges
    - database: {{ pillar['wordpress']['db_name'] }}.*
    - user: {{ pillar['wordpress']['db_user'] }}
    - host: localhost

# Setup WordPress Directory
'/var/www/wordpress':
  file.directory:
    - user: wordpress
    - group: wordpress
    - mode: 750

# Symlink WordPress folder to user's home directory
'ln -s /var/www/wordpress /home/wordpress/wordpress':
  cmd.run:
    - unless: ls /home/wordpress/wordpress && ls /var/www/wordpress

'download wordpress':
  cmd.run:
    - name: wp core download
    - runas: wordpress
    - unless: ls /var/www/wordpress/wp-settings.php

'comfig wordpress':
  cmd.run:
    - name: wp config create --dbpass='{{ pillar['wordpress']['db_pass'] }}'
    - runas: wordpress
    - unless: ls /var/www/wordpress/wp-config.php

'install wordpress':
  cmd.run:
    - name: wp core install --skip-email --admin_password='{{ pillar['wordpress']['admin_pass'] }}'
    - runas: wordpress
    - unless: wp core is-installed

'update wpadmin password':
  cmd.run:
    - name: wp user update wpadmin --user_pass='{{ pillar['wordpress']['admin_pass'] }}'
    - runas: wordpress
    - unless: wp user check-password wpadmin '{{ pillar['wordpress']['admin_pass'] }}'

# Setup permissions
'set_wordpress_permissions':
  file.directory:
    - name: /var/www/wordpress
    - user: wordpress
    - group: wordpress
    - dir_mode: 750
    - file_mode: 640
    - recurse:
      - user
      - group
      - mode


