#!/bin/bash

export CONTAINER="consul-01"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

docker run --name  $CONTAINER \
	--hostname $CONTAINER \
	--net marvel_dc \
	--dns 127.0.0.1 \
	--ip 172.16.10.1 \
	--publish 8300:8300 \
	--publish 8301:8301 \
	--publish 8301:8301/udp \
	--publish 8302:8302 \
	--publish 8302:8302/udp \
	--publish 8500:8500 \
	--publish 8600:8600 \
	--publish 8600:8600/udp \
	--detach \
	consul-server
