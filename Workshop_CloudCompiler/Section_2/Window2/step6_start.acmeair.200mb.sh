# ACMEAIR_PROPERTIES=/config/mongo.properties
export JITSERVER_HOST=localhost
export JITSERVER_PORT=38400
export JITSERVER_OPTS="-XX:+UseJITServer -XX:JITServerAddress=$JITSERVER_ADDRESS -XX:JITServerPort=$JITSERVER_PORT"
export ACMEAIR_IMAGE="liberty-acmeair:17"
export ACMEAIR_OPTS=$JITSERVER_OPTS

podman run --replace --network=host -e JVM_ARGS="$ACMEAIR_OPTS"   -m=200m --cpus=1 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_jitserver_400mb $ACMEAIR_IMAGE

