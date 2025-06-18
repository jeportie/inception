#!/bin/bash

service php7.4-fpm start

# Vérifie si WordPress n'est pas encore configuré
if [ ! -f /var/www/html/wp-config.php ]; then
    # Télécharge WordPress
    wget https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz --strip-components=1 -C /var/www/html
    rm latest.tar.gz

    # Génération de wp-config.php proprement avec WP-CLI
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    wp config create \
        --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    sleep 5 # Attendre que MariaDB soit disponible

    # Installation automatique de WordPress avec WP-CLI
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email --allow-root

    # Création utilisateur supplémentaire
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --path=/var/www/html \
        --allow-root
fi

service php7.4-fpm stop

# Lance php-fpm en mode foreground
exec /usr/sbin/php-fpm7.4 -F
