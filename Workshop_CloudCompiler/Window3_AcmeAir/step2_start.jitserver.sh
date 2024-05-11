#podman run -d --rm -p 38400:38400 --cpus=2.0 --memory=2G -e OPENJ9_JAVA_OPTIONS=:"-XX:+JITServerLogConnections -XX:+JITServerUseAOTCache" --name jitserver jitserver:17
#podman run -d --rm -p 38400:38400 -p 38500:38500 --cpus=2 --memory=1G -e OPENJ9_JAVA_OPTIONS="-XX:+JITServerLogConnections -XX:+JITServerMetrics" --name jitserver jitserver:17

# Start Semeru Cloud Compiler with 2 CPUs and 1GB memory
podman run --network=host -d --rm --cpus=2 --memory=1G -e OPENJ9_JAVA_OPTIONS="-XX:+JITServerLogConnections -XX:+JITServerMetrics" --name jitserver jitserver:17
