#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="vault_s1"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

		#--detach \
docker run --name $CONTAINER \
		--hostname $HOSTNAME \
		--net marvel_dc \
		--ip 172.16.30.1 \
		--publish ${BIND}:8200:8200 \
		--publish ${BIND}:8201:8201 \
		--cap-add IPC_LOCK \
		vault	

