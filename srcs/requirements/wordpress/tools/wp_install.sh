#!/bin/bash
set -Eeuo pipefail

# mkdir -p /run/php
service php7.4-fpm start

until mysqladmin ping -h mariadb -u${MYSQL_USER} -p${MYSQL_PASSWORD} --silent; do
  echo "[WP] Waiting for MariaDB…"
  sleep 2
done

# 1) If /var/www/html is empty, download WP core
if [ -z "$(ls -A /var/www/html)" ]; then
  echo "[WP] Downloading WordPress core…"
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
  tar xzvf /tmp/wordpress.tar.gz --strip-components=1 -C /var/www/html
  rm /tmp/wordpress.tar.gz
fi

cd /var/www/html

# 2) Generate wp-config.php if missing
if [ ! -f wp-config.php ]; then
  echo "[WP] Generating wp-config.php"
  wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --skip-check
fi

# 3) Run core install if needed
if ! wp core is-installed --allow-root; then
  echo "[WP] Installing WordPress"
  wp core install --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email
fi

# 4) Create extra user if it doesn’t exist
# if ! wp user get "${WP_USER}" --allow-root &> /dev/null; then
#   echo "[WP] Creating user ${WP_USER}"
#   wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
#     --role=author \
#     --user_pass="${WP_USER_PASSWORD}" \
#     --allow-root
# fi

service php7.4-fpm stop
exec /usr/sbin/php-fpm7.4 -F
