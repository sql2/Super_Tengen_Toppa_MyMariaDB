#!/bin/bash

 export CONTAINER="consul-server-01"

docker exec -it $CONTAINER consul force-leave $1
