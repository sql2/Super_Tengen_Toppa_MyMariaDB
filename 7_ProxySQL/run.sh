#!/bin/bash

docker stop proxysql 2>&1
docker rm   proxysql 2>&1

docker run --name proxysql \
		--hostname proxysql \
		--net marvel_dc \
		--dns 127.0.0.1
		--ip 172.16.70.1 \
		--publish 3366:3306 \
		--publish 6032:6032 \
		--publish 6080:6080 \
		--detach \
		proxysql	

