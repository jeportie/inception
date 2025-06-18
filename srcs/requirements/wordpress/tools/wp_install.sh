#!/bin/bash

service php7.4-fpm start

if [ ! -f /var/www/html/wp-config.php ]; then
    wget https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz --strip-components=1 -C /var/www/html
    rm latest.tar.gz

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
    sed -i "s/localhost/mariadb/" /var/www/html/wp-config.php

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    sleep 5 # attendre MariaDB opérationnelle
    wp core install --path=/var/www/html \
        --url="https://localhost:8443" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --role=author --user_pass=${WP_USER_PASSWORD} \
        --path=/var/www/html --allow-root
fi

service php7.4-fpm stop

exec /usr/sbin/php-fpm7.4 -F
