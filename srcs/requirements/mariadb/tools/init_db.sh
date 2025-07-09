#!/bin/bash
set -Eeuo pipefail

DATADIR=/var/lib/mysql
INSTALL_MARK="$DATADIR/.installed"

chown -R mysql:mysql "$DATADIR"

# Si fichier existe, alors on saute prochaine etape.
if [ ! -f "$INSTALL_MARK" ]; then
	echo "[MariaDB] Initialisation du répertoire de données…"
	mysql_install_db --user=mysql --datadir="$DATADIR"

	echo "[MariaDB] Démarrage temporaire de mariadbd…"
	# mysqld_safe --datadir="$DATADIR" --bind-address=0.0.0.0 &
	su mysql -s /bin/bash -c "mysqld_safe --datadir=$DATADIR --bind-address=0.0.0.0" &
	PID_TMP=$!
	
	echo "[MariaDB] En attente d’un ping socket…"
	for i in $(seq 1 20); do
	  mysqladmin ping --silent && break
	  sleep 1
	done
	
	# 2) Configuration initiale (root via socket, puis set password)
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
	  -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
	  -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
	  -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
	  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
	  -e "FLUSH PRIVILEGES;"
	
	touch "$INSTALL_MARK"
	
	echo "[MariaDB] Arrêt du serveur temporaire…"
	mysqladmin shutdown -uroot -p"${MYSQL_ROOT_PASSWORD}"
fi

echo "[MariaDB] Démarrage final en avant-plan…"
exec su mysql -s /bin/bash -c "mysqld_safe --datadir=$DATADIR --bind-address=0.0.0.0"
# exec mysqld_safe --datadir="$DATADIR" --bind-address=0.0.0.0

