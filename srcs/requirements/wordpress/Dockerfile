FROM debian:bullseye

RUN apt-get update && \
	apt-get install -y php php-fpm php-mysql mariadb-client curl wget sendmail tar

RUN mkdir -p /var/www/html

COPY tools/wp_install.sh /tmp/wp_install.sh
RUN chmod +x /tmp/wp_install.sh

RUN sed -i 's/listen = .*/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf

EXPOSE 9000

CMD ["/tmp/wp_install.sh"]
