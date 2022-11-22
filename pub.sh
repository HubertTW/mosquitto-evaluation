#!/bin/bash

while true;
do
	./client/mosquitto_pub -h localhost -p 3456 -t topic -m hi 2> /dev/null
	sleep 0.$(( $RANDOM % 99 + 1 ))
done
