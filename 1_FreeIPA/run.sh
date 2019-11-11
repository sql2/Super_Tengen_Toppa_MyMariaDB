#!/bin/bash

export BIND="0.0.0.0"
export CONTAINER="ipa"
export HOSTNAME="$CONTAINER.example.test"
export IPA_DATA="$HOME/ipa-data"

mkdir -p $IPA_DATA

sudo setsebool -P container_manage_cgroup 1

#-p ${BIND}:53:53/udp -p ${BIND}:53:53 \
docker run --name $CONTAINER -it \
	--hostname $HOSTNAME \
	--net marvel_dc \
	--ip 172.16.10.1 \
	--sysctl net.ipv6.conf.all.disable_ipv6=0 \
	-p ${BIND}:80:80 -p ${BIND}:443:443 \
	-p ${BIND}:389:389 -p ${BIND}:636:636 \
	-p ${BIND}:88:88 -p ${BIND}:464:464 -p ${BIND}:88:88/udp -p ${BIND}:464:464/udp -p ${BIND}:749:749 \
	-p ${BIND}:123:123/udp \
	-p ${BIND}:8005:8005 -p ${BIND}:8009:8009 -p ${BIND}:8080:8080 -p ${BIND}:8443:8443 \
	-v $IPA_DATA:/data:Z \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	--tmpfs /run --tmpfs /tmp freeipa/freeipa-server --no-ui-redirect


# $ vim /etc/hosts
# 10.0.2.15   ipa.example.test

# $ c:\windows~
# 10.0.2.15   ipa.example.test
