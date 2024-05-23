# ACMEAIR_PROPERTIES=/config/mongo.properties
export ACMEAIR_IMAGE="liberty-acmeair-9090:17"
export ACMEAIR_OPTS=

podman run --rm --network=host -m=225m --cpus=1 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_baseline_225m $ACMEAIR_IMAGE

