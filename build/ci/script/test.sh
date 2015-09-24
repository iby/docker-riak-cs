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

echo -n 'Checking if riak-cs container running…'
if [ $(docker inspect --format '{{ .State.Running }}' riak-cs) == 'true' ]; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain admin credentials…'
if echo "$LOGS" | grep -q '^[[:blank:]]*Key: .\{20\}$' && echo "$LOGS" | grep -q '^[[:blank:]]*Secret: .\{40\}$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain foo bucket success status…'
if echo "$LOGS" | grep -q '^foo… OK!$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain bar bucket success status…'
if echo "$LOGS" | grep -q '^bar… OK!$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain baz bucket success status…'
if echo "$LOGS" | grep -q '^baz… OK!$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;