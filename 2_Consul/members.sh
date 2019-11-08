#!/bin/bash

export CONTAINER="consul_s1"

docker exec -it $CONTAINER consul members  
