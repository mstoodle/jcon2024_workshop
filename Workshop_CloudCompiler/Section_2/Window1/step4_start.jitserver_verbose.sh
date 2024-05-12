podman run --network=host --rm --cpus=2 --memory=1G -e OPENJ9_JAVA_OPTIONS="-XX:+JITServerLogConnections -XX:+JITServerMetrics -Xjit:verbose={compilePerformance}" --name jitserver jitserver:17
