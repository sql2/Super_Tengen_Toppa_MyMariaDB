#!/bin/bash

docker network rm marvel_dc

docker network create \
                --opt "com.docker.network.bridge.name"="marvel_dc" \
                --driver=bridge \
                --ip-range=172.16.1.1/24 \
                --subnet=172.16.0.0/16 \
                --gateway=172.16.1.254 \
                marvel_dc
