podman run -d --rm -p 9000:9090 -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml --name prometheus    docker.io/prom/prometheus
