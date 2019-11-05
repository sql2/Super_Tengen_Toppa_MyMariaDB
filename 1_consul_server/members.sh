#!/bin/bash

export CONTAINER="consul-01"

docker exec -it $CONTAINER consul members  
