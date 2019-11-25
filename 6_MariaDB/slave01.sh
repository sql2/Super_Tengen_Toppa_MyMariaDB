#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="slave01"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

docker run --name  $CONTAINER \
	--hostname $HOSTNAME \
	--net marvel_dc \
	--dns-search "example.test" \
	--ip 172.16.60.2 \
	--publish 3307:3306 \
	--detach \
	mariadb-server

