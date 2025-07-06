#!/bin/bash
set -Eeuo pipefail

service php7.4-fpm start

until mysqladmin ping -h mariadb -u${MYSQL_USER} -p${MYSQL_PASSWORD} --silent; do
  echo "[WP] En attente de MariaDB…"
  sleep 2
done

if [ ! -f /var/www/html/wp-settings.php ]; then
  echo "[WP] Telechargement de WordPress…"
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
  tar xzvf /tmp/wordpress.tar.gz --strip-components=1 -C /var/www/html
  rm /tmp/wordpress.tar.gz
fi

cd /var/www/html

if [ ! -f wp-config.php ]; then
  echo "[WP] Generation du fichier wp-config.php…"
  wp config create \
	--allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --skip-check
fi

if ! wp core is-installed --allow-root; then
  echo "[WP] Installation de WordPress…"
  wp core install \
	--allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email
fi

if ! wp user get "${WP_USER}" --allow-root; then
  echo "[WP] Creation du nouvel utilisateur… ${WP_USER}"
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --role=author \
    --user_pass="${WP_USER_PASSWORD}" \
    --allow-root
fi

service php7.4-fpm stop
exec /usr/sbin/php-fpm7.4 -F
