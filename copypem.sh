#!/bin/bash

while :
do
	docker ps|grep $2
	if [ $? -eq 0 ]; then
		conatinerid=`docker ps|grep $2|awk -F ' ' '{ print $1 }'`
		break
	fi
	sleep 1
done

pemfile=$1

docker cp $pemfile $conatinerid:/
docker exec -it $conatinerid chmod 400 /$pemfile
