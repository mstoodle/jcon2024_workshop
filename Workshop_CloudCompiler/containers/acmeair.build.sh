#!/bin/bash
# Note: a mongo-acmeair image must already exist on the system
export DOCKER_BUILDKIT=0
ACMEAIR_CONTAINER_NAME="liberty-acmeair:17"
DOCKERFILE="acmeair.Dockerfile"
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
  podman build -m=1024m --network=$NET_NAME -f $DOCKERFILE -t $ACMEAIR_CONTAINER_NAME .
  stopMongo
else
  echo "liberty-acmeair container not created"
fi
# If a new network was created, delete it now
if [[ $networkCreated -eq 0 ]]; then 
  echo "Deleting podman network $NET_NAME"
  podman network rm $NET_NAME
fi
