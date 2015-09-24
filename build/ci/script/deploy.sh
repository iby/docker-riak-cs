#!/usr/bin/env bash

# Setup error trapping.

set -e
trap 'echo "Error occured on line $LINENO." && exit 1' ERR

# Authenticate with docker and push the latest image.

docker login \
    --email $DOCKER_HUB_EMAIL \
    --password $DOCKER_HUB_PASSWORD \
    --username $DOCKER_HUB_USER

docker push ianbytchek/riak-cs
docker logout