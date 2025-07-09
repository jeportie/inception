FROM debian:bullseye
EXPOSE 9000

# Installer PHP-FPM, CLI, extensions & outils
RUN apt-get update && \
	apt-get install -y \
	php7.4-fpm php7.4-cli \
	php7.4-mysql php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-gd \
	mariadb-client curl wget sendmail tar && \
	apt-get clean

# Créer répertoires + utilisateur non-root
RUN mkdir -p /var/www/html /run/php /var/log/php && \
	useradd -u 1000 -ms /bin/bash appuser && \
	chown -R appuser:appuser /var/www/html /run/php /var/log/php

# Installer WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp && \
	chown appuser:appuser /usr/local/bin/wp

# Forcer PHP-FPM à écouter sur TCP/9000 pour être compatible avec Nginx
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf && \
    # sed -i 's/^user = .*/user = appuser/' /etc/php/7.4/fpm/pool.d/www.conf && \
    # sed -i 's/^group = .*/group = appuser/' /etc/php/7.4/fpm/pool.d/www.conf && \
    # sed -i 's/^listen.owner = .*/listen.owner = appuser/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/^listen.group = .*/listen.group = appuser/' /etc/php/7.4/fpm/pool.d/www.conf

# Remplace tous les chemins d'erreur log par la sortie standard (stderr)
RUN find /etc/php/7.4/fpm -name "*.conf" -exec sed -i 's|^error_log = .*|error_log = /proc/self/fd/2|' {} \;

# Copier le script d’installation
COPY tools/wp_install.sh /tmp/wp_install.sh
RUN chmod +x /tmp/wp_install.sh && \
	chown appuser:appuser /tmp/wp_install.sh

USER appuser

CMD ["/tmp/wp_install.sh"]
