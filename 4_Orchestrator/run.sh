#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="orchestrator_s1"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

docker run --name $CONTAINER \
		--hostname $HOSTNAME \
		--net marvel_dc \
		--dns 127.0.0.1 \
		--ip 172.16.40.1 \
		--publish ${BIND}:3000:3000 \
		--detach \
		orchestrator	

