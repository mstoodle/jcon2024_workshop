#!/bin/bash


podman --runtime runc run \
  --rm -p 9080:9080 \
  --cap-add=CHECKPOINT_RESTORE \
  --cap-add=SETPCAP \
  --security-opt seccomp=unconfined \
  -e OPENJ9_RESTORE_JAVA_OPTIONS='-Xtrace:print=j9vm.2' \
  dev.local/getting-started-instanton-demo

