FROM debian:bullseye

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client

COPY tools/init_db.sh /tmp/init_db.sh
RUN chmod +x /tmp/init_db.sh

EXPOSE 3306

CMD ["/tmp/init_db.sh"]
