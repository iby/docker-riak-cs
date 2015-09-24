#!/usr/bin/env bash

# Setup error trapping.

set -e
trap 'echo "Error occured on line $LINENO." && exit 1' ERR

# Build docker image.

docker build --tag "ianbytchek/riak-cs" "./src"