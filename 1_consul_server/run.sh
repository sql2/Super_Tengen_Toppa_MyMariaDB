#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="consul-01"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

docker run --name  $CONTAINER \
	--hostname $HOSTNAME \
	--net marvel_dc \
	--dns 127.0.0.1 \
	--ip 172.16.10.1 \
	--publish ${BIND}:8300:8300 \
	--publish ${BIND}:8301:8301 \
	--publish ${BIND}:8301:8301/udp \
	--publish ${BIND}:8302:8302 \
	--publish ${BIND}:8302:8302/udp \
	--publish ${BIND}:8500:8500 \
	--publish ${BIND}:8600:8600 \
	--publish ${BIND}:8600:8600/udp \
	--detach \
	consul-server
