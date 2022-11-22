#!/bin/bash

if [[ "$#" -ne 1 ]]; then
	echo "Error: need to give one parameter!"
	echo "Usage: $0 #-of-data-streams"
	echo "Example: $0 100"
	exit 2
fi

N=$1
# Starting the Mosquitto broker
./src/mosquitto -p 3456 -c ./mosquitto.conf 2> tmp &
sleep 2
# Starting publishers
for i in $(seq 1 $N); do
	bash ./pub.sh &
	sleep 0.1
done
echo "Finished starting all publishers"

# Keep collecting data
sleep 500
# Killing all publishers
bash ./kill_pubs.sh
sleep 10
# Killing the broker
bash ./kill_brokers.sh
sleep 2
# Parsing data
awk 'NR==1 {t_prev=$1}\
	NR > 1 {print ($1-t_prev); t_prev=$1}' ./tmp > interarrivals.out
