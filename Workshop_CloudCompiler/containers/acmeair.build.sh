#!/bin/bash
# Note: this script assumes a mongo-acmeair image already exists on the system

export DOCKER_BUILDKIT=0
ACMEAIR_CONTAINER_NAME_9090="liberty-acmeair-9090:17"
ACMEAIR_CONTAINER_NAME_9091="liberty-acmeair-9091:17"
ACMEAIR_CONTAINER_NAME_9092="liberty-acmeair-9092:17"
DOCKERFILE_9090="acmeair.9090.Dockerfile"
DOCKERFILE_9091="acmeair.9091.Dockerfile"
DOCKERFILE_9092="acmeair.9092.Dockerfile"
NET_NAME="my-net"

function startMongo() 
{
  podman run --rm -d --name mongodb --network=$NET_NAME mongo-acmeair:5.0.15 --nojournal && \
    sleep 1 && \
    podman exec mongodb mongorestore --drop /AcmeAirDBBackup		
}
function stopMongo()
{
  echo "Stopping mongodb container ..."
  podman stop mongodb
}

podman network create $NET_NAME
networkCreated=$?

stopMongo
sleep 1

startMongo
if [[ $? -eq 0 ]]; then
  podman build -m=1024m --network=$NET_NAME -f $DOCKERFILE_9090 -t $ACMEAIR_CONTAINER_NAME_9090 .
  podman build -m=1024m --network=$NET_NAME -f $DOCKERFILE_9091 -t $ACMEAIR_CONTAINER_NAME_9091 .
  podman build -m=1024m --network=$NET_NAME -f $DOCKERFILE_9092 -t $ACMEAIR_CONTAINER_NAME_9092 .
  stopMongo
else
  echo "liberty-acmeair containers not created"
fi

# If a new network was created, delete it now
if [[ $networkCreated -eq 0 ]]; then 
  echo "Deleting podman network $NET_NAME"
  podman network rm $NET_NAME
fi
