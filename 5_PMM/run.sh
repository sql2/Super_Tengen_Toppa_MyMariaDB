#!/bin/bash

docker stop pmm-server 2>&1
docker rm   pmm-server 2>&1
docker rm   pmm-data 2>&1

docker create --name pmm-data \
   --volume /opt/prometheus/data \
   --volume /opt/consul-data \
   --volume /var/lib/mysql \
   --volume /var/lib/grafana \
   percona/pmm-server:latest /bin/true

docker run --name pmm-server \
	--hostname pmm-server \
	--volumes-from pmm-data \
	--restart always \
	--net marvel_dc \
	--dns-search "example.test" \
	--ip 172.16.50.1 \
	--publish 580:80 \
	--publish 5443:443 \
	--env ORCHESTRATOR_ENABLED=false \
	--detach \
	percona/pmm-server

docker exec -it consul_s1 consul kv put pmm-server "172.16.50.1"
