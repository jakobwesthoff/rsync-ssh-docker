#!/bin/sh
docker buildx build \
--push \
--platform linux/arm64/v8 \
--platform linux/arm/v7 \
--platform linux/amd64 \
--platform linux/386  \
--tag jakobwesthoff/rsync-ssh:2.0.0 .
