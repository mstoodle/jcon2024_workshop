export MONGO_HOST="localhost"

podman run --rm --network=host -e JPORT=9090 -e JUSERBOTTOM=0 -e JUSER=199 -e JURL=acmeair-webapp -e JTHREAD=4 -e JDURATION=300 --name jmeter jmeter-acmeair:5.4.3 $MONGO_HOST
