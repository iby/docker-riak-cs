#!/usr/bin/env bash

# Setup error trapping.

set -e
trap 'echo "Error occured on line $LINENO." && exit 1' ERR

# Run riak cs and sleep for 30 seconds allowing it to initialise.

echo -n 'Starting riak-cs container…'
docker run \
    --detach \
    --env 'RIAK_CS_BUCKETS=foo,bar,baz' \
    --name 'riak-cs' \
    --publish '8080:8080' \
    ianbytchek/riak-cs > /dev/null
echo ' OK!'

sleep 45


# Print docker logs and check that we have credentials and buckets succesfully setup.

LOGS=$(docker logs riak-cs)
echo "$LOGS"

# First check that container is running.

if [ $(docker inspect --format '{{ .State.Running }}' riak-cs) != 'true' ]; then
    echo "The container is not even running, things are THAT BAD!"
    exit 1
elif ! echo "$LOGS" | grep -q '^[[:blank:]]*Key: *.\{20\}$' || ! echo "$LOGS" | grep -q '^[[:blank:]]*Secret: *.\{40\}$'; then
    echo "Failed asserting that container logs reported admin credentials."
    exit 1
elif ! echo "$LOGS" | grep -q '^foo… OK!$'; then
    echo "Failed asserting that container logs reported foo bucket creation."
    exit 1
elif ! echo "$LOGS" | grep -q '^bar… OK!$'; then
    echo "Failed asserting that container logs reported bar bucket creation."
    exit 1
elif ! echo "$LOGS" | grep -q '^baz… OK!$'; then
    echo "Failed asserting that container logs reported baz bucket creation."
    exit 1
fi
