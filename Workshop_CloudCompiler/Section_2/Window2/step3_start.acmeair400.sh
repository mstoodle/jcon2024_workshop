# ACMEAIR_PROPERTIES=/config/mongo.properties
export JITSERVER_HOST=localhost
export JITSERVER_PORT=38400
export JITSERVER_OPTS="-XX:+UseJITServer -XX:JITServerAddress=$JITSERVER_HOST -XX:JITServerPort=$JITSERVER_PORT"
export ACMEAIR_IMAGE="liberty-acmeair-9090:17"
export ACMEAIR_OPTS=$JITSERVER_OPTS

podman run --replace --network=host -e JVM_ARGS="$ACMEAIR_OPTS"   -m=400m --cpus=1 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_jitserver_400mb $ACMEAIR_IMAGE

