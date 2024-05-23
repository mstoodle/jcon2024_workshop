# ACMEAIR_PROPERTIES=/config/mongo.properties
export ACMEAIR_IMAGE="liberty-acmeair1:17"
export ACMEAIR_OPTS=

podman run --rm --network=host -d  -m=200m --cpus=1 -p 9090:9090 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_baseline $ACMEAIR_IMAGE

