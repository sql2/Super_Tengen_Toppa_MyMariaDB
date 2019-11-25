#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="slave2"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

docker run --name  $CONTAINER \
	--hostname $HOSTNAME \
	--net marvel_dc \
	--dns-search "example.test" \
	--ip 172.16.60.3 \
	--publish 3308:3306 \
	--detach \
	mariadb-server

