#!/bin/bash
set -Eeuo pipefail

echo "[WP] En attente de MariaDB…"
until mysqladmin ping -h mariadb -u${MYSQL_USER} -p${MYSQL_PASSWORD} --silent; do
  sleep 2
done

cd /var/www/html

if [ ! -f wp-settings.php ]; then
  echo "[WP] Téléchargement de WordPress…"
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
  tar xzvf /tmp/wordpress.tar.gz --strip-components=1 -C /var/www/html
  rm /tmp/wordpress.tar.gz
fi

if [ ! -f wp-config.php ]; then
  echo "[WP] Génération de wp-config.php…"
  wp config create \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --skip-check
fi

if ! wp core is-installed; then
  echo "[WP] Installation de WordPress…"
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email

# eviter les redirection infinit et la perte de session en forcant https
  wp option update home "https://${DOMAIN_NAME}"
  wp option update siteurl "https://${DOMAIN_NAME}"
fi

if ! wp user get "${WP_USER}"; then
  echo "[WP] Création du nouvel utilisateur… ${WP_USER}"
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --role=author \
    --user_pass="${WP_USER_PASSWORD}"
fi

echo "[WP] Démarrage de php-fpm..."
exec php-fpm7.4 -F
