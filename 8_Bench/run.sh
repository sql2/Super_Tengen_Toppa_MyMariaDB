#!/bin/bash

export MYSQL_PWD="sandbox"

while true
do
	# proxysql - insert
	echo -n "ProxySQL : "
	mysql --silent --skip-column-names \
		-h 127.0.0.1 \
		-P 3366 \
		-usandbox \
		-e "INSERT INTO dummy.tbl VALUES ( 1 );"

	# master direct
	echo -n "Master   : "
	mysql --silent --skip-column-names \
		-h 127.0.0.1 \
		-P 3306 \
		-usandbox \
		-e "SELECT 'direct ->', @@hostname, COUNT(*) FROM dummy.tbl;"

	# slave-1 direct
	echo -n "Slave01  : "
	mysql --silent --skip-column-names \
		-h 127.0.0.1 \
		-P 3307 \
		-usandbox \
		-e "SELECT 'direct ->', @@hostname, COUNT(*) FROM dummy.tbl;"
	
	# slave-2 direct
	echo -n "Slave02  : "
	mysql --silent --skip-column-names \
		-h 127.0.0.1 \
		-P 3308 \
		-usandbox \
		-e "SELECT 'direct ->', @@hostname, COUNT(*) FROM dummy.tbl;"
	
	# proxysql - select
	echo -n "ProxySQL : "
	mysql --silent --skip-column-names \
		-h 127.0.0.1 \
		-P 3366 \
		-usandbox \
		-e "SELECT 'proxysql ->', @@hostname, COUNT(*) FROM dummy.tbl;"

	echo ""
	echo "--------------------------------------------------------------------------------"
	echo ""

	sleep 3 
done
