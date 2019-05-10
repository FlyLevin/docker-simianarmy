#!/bin/bash

conatinerid=`docker ps|grep $2|awk -F ' ' '{ print $1 }'`
pemfile=$1

docker cp $pemfile $conatinerid:/
docker exec -it $conatinerid chmod 400 /$pemfile
