#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="master"
export HOSTNAME="$CONTAINER.example.test"

docker stop $CONTAINER 2>&1
docker rm   $CONTAINER 2>&1

#sudo setsebool -P container_manage_cgroup 1

#docker run --privileged --cap-add SYS_ADMIN --security-opt seccomp=unconfined --name $CONTAINER \
docker run --name $CONTAINER \
	--hostname $HOSTNAME \
	--net marvel_dc \
	--dns-search "example.test" \
	--ip 172.16.60.1 \
	--publish 3306:3306 \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	--tmpfs /run --tmpfs /tmp \
	--detach \
	mariadb-server

