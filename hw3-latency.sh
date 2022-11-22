#!/bin/bash
# Note that $1 is the first command-line argument
if [[ "$#" -ne 1 ]]; then
	echo "Error: need to give one parameter!"
	echo "Usage: $0 #-of-publishers"
	echo "Example: $0 7"
	exit 2
fi

echo "Starting the broker.."
./src/mosquitto -p 3456 -c ./mosquitto.conf 2> broker.out &

sleep 1

echo "Starting the subscriber.."
./client/mosquitto_sub -h localhost -p 3456 -t topic 2> sub.out > /dev/null &

sleep 1

echo "Starting the publisher(s).."
for i in $(seq 1 $1); do
	./client/mosquitto_pub -h localhost -p 3456 -t topic -m hi 2>> pub.out
	sleep 1
done
killall mosquitto_sub
killall ./src/mosquitto

paste pub.out broker.out sub.out > overall.out
awk '{printf "Pub2sub: %ld us;\tpub2broker: %ld us;\
\twithin-broker: %ld us;\tbroker2sub: %ld us\n",\
$4-$1, $2-$1, $3-$2, $4-$3}' overall.out
echo "Backing up the output files.."
mv broker.out broker.out.prev
mv sub.out sub.out.prev
mv pub.out pub.out.prev

echo "Done!"
