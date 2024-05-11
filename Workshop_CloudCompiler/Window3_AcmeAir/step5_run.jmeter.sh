export MONGO_HOST="localhost"
#export MONGO_HOST="9.42.142.175"

podman run --rm -d --network=host -e JINFLUXDBBUCKET=jmeter  -e JPORT=9090 -e JUSERBOTTOM=0 -e JUSER=199 -e JURL=acmeair-webapp -e JTHREAD=4 -e JDURATION=300 --name jmeter1 jmeter-acmeair:5.4.3-influxdb $MONGO_HOST
podman run --rm -d --network=host -e JINFLUXDBBUCKET=jmeter2 -e JPORT=9092 -e JUSERBOTTOM=0 -e JUSER=199 -e JURL=acmeair-webapp -e JTHREAD=4 -e JDURATION=300 --name jmeter2 jmeter-acmeair:5.4.3-influxdb $MONGO_HOST
podman run --rm -d --network=host -e JINFLUXDBBUCKET=jmeter3 -e JPORT=9093 -e JUSERBOTTOM=0 -e JUSER=199 -e JURL=acmeair-webapp -e JTHREAD=4 -e JDURATION=300 --name jmeter3 jmeter-acmeair:5.4.3-influxdb $MONGO_HOST
