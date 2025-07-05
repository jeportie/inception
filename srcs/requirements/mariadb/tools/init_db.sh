#!/bin/bash
set -ex

DATADIR=/var/lib/mysql

# 0) S’assurer du bon propriétaire
chown -R mysql:mysql "$DATADIR"

# 1) Initialisation si /var/lib/mysql/mysql n’existe pas

INSTALL_MARK="$DATADIR/.installed"

if [ ! -f "$INSTALL_MARK" ]; then
	echo "[MariaDB] Initialisation du répertoire de données…"
	mysql_install_db --user=mysql --datadir="$DATADIR"

	# 2) Démarrage temporaire
	echo "[MariaDB] Démarrage temporaire de mariadbd…"
	mysqld_safe --datadir="$DATADIR" --bind-address=0.0.0.0 &
	PID_TMP=$!
	
	# 3) Attente active (socket Unix, root n’a pas encore de mot de passe)
	echo "[MariaDB] En attente d’un ping socket…"
	for i in $(seq 1 20); do
	  mysqladmin ping --silent && break
	  sleep 1
	done
	
	# 4) Configuration initiale (root via socket, puis set password)
	echo "[MariaDB] Configuration initiale…"
	mysql <<-EOSQL
	  ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}');
	  CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
	  CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	  GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
	  FLUSH PRIVILEGES;
	EOSQL
	
	touch "$INSTALL_MARK"
	
	# 5) Arrêt du serveur temporaire (cette fois avec mot de passe)
	echo "[MariaDB] Arrêt du serveur temporaire…"
	mysqladmin shutdown -uroot -p"${MYSQL_ROOT_PASSWORD}"
fi

# 6) Démarrage final (foreground)
echo "[MariaDB] Démarrage final en avant-plan…"
exec mysqld_safe --datadir="$DATADIR" --bind-address=0.0.0.0

