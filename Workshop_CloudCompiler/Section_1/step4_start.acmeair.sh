# ACMEAIR_PROPERTIES=/config/mongo.properties
export ACMEAIR_IMAGE="liberty-acmeair:17"
export ACMEAIR_OPTS='-Xjit:verbose={compilePeformance}'

podman run --replace --network=host -d  -e JVM_ARGS="$ACMEAIR_OPTS"   -m=400m --cpus=1 -p 9090:9090 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_baseline $ACMEAIR_IMAGE

