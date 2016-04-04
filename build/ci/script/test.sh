#!/usr/bin/env bash

# Setup error trapping.

set -e
trap 'echo "Error occurred on line $LINENO." && exit 1' ERR

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

# Print docker logs and check that we have credentials and buckets successfully setup.

LOGS=$(docker logs riak-cs)
echo "$LOGS"

# First check that container is running.

echo -n 'Checking if riak-cs container running…'
if [ $(docker inspect --format '{{ .State.Running }}' riak-cs) == 'true' ]; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

access_key=$(echo "$LOGS" | grep -oP '^\h*Access key:\h*\K(.{20})$' || echo '')
secret_key=$(echo "$LOGS" | grep -oP '^\h*Secret key:\h*\K(.{40})$' || echo '')

echo -n 'Checking if container logs contain admin credentials…'
if [ -n "$access_key" ] && [ -n "$secret_key" ]; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain foo bucket success status…'
if echo "$LOGS" | grep -Pq '^foo… OK!$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain bar bucket success status…'
if echo "$LOGS" | grep -Pq '^bar… OK!$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

echo -n 'Checking if container logs contain baz bucket success status…'
if echo "$LOGS" | grep -Pq '^baz… OK!$'; then
echo ' OK!'; else echo ' Fail!'; exit 1; fi;

# Now lets use s3cmd to actually connect to our riak cs service and run some tests on it.

cat <<-EOL > configuration
	[default]
	access_key = $access_key
	host_base = s3.amazonaws.dev
	host_bucket = %(bucket)s.s3.amazonaws.dev
	proxy_host = 127.0.0.1
	proxy_port = 8080
	secret_key = $secret_key
	signature_v2 = True
EOL

echo 'Listing buckets with s3cmd:'
s3cmd --config 'configuration' ls

echo 'Putting file into foo bucket and list it with s3cmd:'
touch 'file'
s3cmd --config 'configuration' put 'file' 's3://foo'
s3cmd --config 'configuration' ls 's3://foo'

echo 'Copying file from foo bucket into bar bucket and list it with s3cmd:'
s3cmd --config 'configuration' cp 's3://foo/file' 's3://bar/file'
s3cmd --config 'configuration' ls 's3://bar'

echo 'Remove file from bar bucket and list it with s3cmd:'
s3cmd --config 'configuration' del 's3://bar/file'
s3cmd --config 'configuration' ls 's3://bar'

echo 'Remove bar bucket and list all buckets with s3cmd:'
s3cmd --config 'configuration' rb 's3://bar'
s3cmd --config 'configuration' ls