FROM debian:bullseye
EXPOSE 9000

# let WP-CLI run as root without screaming
ENV WP_CLI_ALLOW_ROOT=1
# 1) Installer PHP-FPM, CLI, extensions & outils
RUN apt-get update && \
	apt-get install -y \
	php7.4-fpm php7.4-cli \
	php7.4-mysql php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-gd \
	mariadb-client curl wget sendmail tar
# 2) Installer WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp

# Ajuster le pool FPM pour écouter sur le port 9000
RUN sed -i 's/listen = .*/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf

# Copier le script d’installation
COPY tools/wp_install.sh /tmp/wp_install.sh
RUN chmod +x /tmp/wp_install.sh

CMD ["/tmp/wp_install.sh"]
