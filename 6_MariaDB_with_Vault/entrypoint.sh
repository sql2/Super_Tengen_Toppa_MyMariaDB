#!/bin/bash 
# encoding: UTF-8
set -e

echo '[Entrypoint] Setting #node_name.'
HOSTNAME_SHORT=$(hostname -s)
sed -i -e "s/#NODE_NAME/${HOSTNAME_SHORT}/g" /etc/consul.d/consul_client.json

echo '[Entrypoint] dnsmasq test.'
dnsmasq --test

echo '[Entrypoint] dnsmasq start.'
dnsmasq --user=root -8 /var/log/dnsmasq.log

echo '[Entrypoint] Validated consul.'
consul validate -quiet /etc/consul.d

echo '[Entrypoint] Start consul agent.'
consul agent -config-file=/etc/consul.d/consul_client.json &

MYSQL_REPORT_HOST=$(/sbin/ip route | awk '/kernel/ { print $9 }')
MYSQL_SERVER_ID="${MYSQL_REPORT_HOST//./}"

sed -i -e "s/#HOSTNAME/${HOSTNAME_SHORT}/g"       /etc/my.cnf.d/server.cnf 
sed -i -e "s/#REPORT_HOST/${MYSQL_REPORT_HOST}/g" /etc/my.cnf.d/server.cnf
sed -i -e "s/#SERVER_ID/${MYSQL_SERVER_ID}/g"     /etc/my.cnf.d/server.cnf

DATADIR="/var/lib/mysql"
SOCKETDIR="/var/lib/mysql"
SOCKET="/var/lib/mysql/mysql.sock"
CMD=(mysql --protocol=socket -uroot --socket="$SOCKET")

rm -rf "$DATADIR"
mkdir -p "$DATADIR"
chown -R mysql:mysql "$DATADIR"
#> /var/lib/mysql/error.log

echo '[Entrypoint] Initializing database.'
mysql_install_db --user=mysql \
	--basedir=/usr \
	--datadir=$DATADIR
echo '[Entrypoint] Database initialized.'

echo '[Entrypoint] Database Starting.'
mysqld --skip-networking --socket="$SOCKET" &

if [ ! -z " " ] ; then
  for i in {30..0}; do
    if mysqladmin --socket="$SOCKET" ping &>/dev/null; then
      break
    fi
    echo '[Entrypoint] Waiting for server...'
    sleep 1
  done
  if [ "$i" = 0 ]; then
    echo >&2 '[Entrypoint] Timeout during MySQL init.'
    exit 1
  fi
fi

echo "[Entrypoint] Populate TimeZone..."
# With "( .. ) 2> /dev/null" suppress any std[out/err].
(mysql_tzinfo_to_sql /usr/share/zoneinfo/Asia | "${CMD[@]}" mysql --force) 2> /dev/null

echo "[Entrypoint] Create users."
"${CMD[@]}" <<-EOSQL
SET @@SESSION.SQL_LOG_BIN=0;

DROP DATABASE IF EXISTS test;

-- Sample
CREATE DATABASE IF NOT EXISTS dummy;
CREATE TABLE dummy.tbl ( col int );

-- Orch database
CREATE DATABASE IF NOT EXISTS orchestrator;

-- Orch account
GRANT ALL PRIVILEGES ON orchestrator.* TO 'orchestrator'@'%' IDENTIFIED BY 'orchestrator';
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON orchestrator.* TO 'orchestrator'@'localhost' IDENTIFIED BY 'orchestrator';
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON orchestrator.* TO 'orchestrator'@'localhost' IDENTIFIED BY 'orchestrator';

-- Replication
CHANGE MASTER TO MASTER_USER = 'repl', MASTER_PASSWORD = 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.16.40.%' IDENTIFIED BY 'repl';

-- ProxySQL
GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'admin' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP, INDEX ON *.* TO 'sandbox'@'%' IDENTIFIED BY 'sandbox';
GRANT SELECT, CREATE USER, REPLICATION CLIENT, SHOW DATABASES, SUPER, PROCESS ON *.* TO 'monitor'@'%' IDENTIFIED BY 'monitor';

-- PMM
CREATE USER IF NOT EXISTS 'pmm'@'%' IDENTIFIED BY 'pass';
GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'%' IDENTIFIED BY 'pass' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, UPDATE, DELETE, DROP ON performance_schema.* TO 'pmm'@'%';

FLUSH PRIVILEGES;

SET @@SESSION.SQL_LOG_BIN=1;
EOSQL

echo '[Entrypoint] MySQL shutdown.'
mysqladmin shutdown -uroot --socket="$SOCKET"

echo '[Entrypoint] MySQL init process done. Ready for start up.'
mysqld_safe

