FROM debian:bullseye
EXPOSE 3306

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/init_db.sh /tmp/init_db.sh
RUN chmod +x /tmp/init_db.sh

CMD ["/tmp/init_db.sh"]
