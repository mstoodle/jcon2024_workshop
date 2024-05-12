podman run --rm -d --network=host --name=mongodb mongo-acmeair:5.0.15 --nojournal
sleep 2
podman exec  mongodb mongorestore --drop /AcmeAirDBBackup

