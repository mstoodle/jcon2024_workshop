# ACMEAIR_PROPERTIES=/config/mongo.properties
export JITSERVER_HOST=9.42.142.175
export ACMEAIR_IMAGE="liberty-acmeair:17"
export ACMEAIR_OPTS=''
export JITSERVER_OPTS="-XX:+UseJITServer -XX:JITServerAddress=$JITSERER_HOST -XX:+JITServerPort=38400"

podman run --replace --network=host -d  -e JVM_ARGS="$ACMEAIR_OPTS"   -m=400m --cpus=1 -p 9090:9090 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_baseline $ACMEAIR_IMAGE
podman run --replace --network=host -d  -e JVM_ARGS="$ACMEAIR_OPTS"   -m=200m --cpus=1 -p 9092:9090 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_hm $ACMEAIR_IMAGE
podman run --replace --network=host -d  -e JVM_ARGS="$JITSERVER_OPTS" -m=200m --cpus=1 -p 9093:9090 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_jitserver $ACMEAIR_IMAGE

