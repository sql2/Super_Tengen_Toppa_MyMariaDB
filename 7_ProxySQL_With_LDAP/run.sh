#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="proxysql"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

docker run --name $CONTAINER \
	--hostname $HOSTNAME \
	--net marvel_dc \
	--dns 127.0.0.1 \
	--ip 172.16.70.1 \
	--publish ${BIND}:3366:3306 \
	--publish ${BIND}:6032:6032 \
	--publish ${BIND}:6080:6080 \
	--detach \
	proxysql

