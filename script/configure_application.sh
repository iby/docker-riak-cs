#!/usr/bin/env bash

# Make sure we are in the same directory as the script and run relevant scripts in that order.

cd $(dirname $0)
. functions.sh

function riak_cs_bucket_create(){
    local key=$1
    local secret=$2
    local bucket=$3

    # To say this hmac bitch is a motherfucking nonsense is to say nothing… The signed string has to match to a single
    # space and character. If it doesn't, it won't work.

    date="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
    signature="$(printf "PUT\n\n\n\nx-amz-date:${date}\n/${bucket}/" | openssl sha1 -binary -hmac "${secret}" | base64)"

    echo -n "${bucket}"

    curl -ks -X PUT "/${bucket}/" "http://127.0.0.1:8080" \
        -H "Host: ${bucket}.s3.amazonaws.dev" \
        -H "x-amz-date: ${date}" \
        -H "Authorization: AWS ${key}:${signature}"

    echo ' OK!'
}

#
# @param $1 Command name.
# @param $1 Service name.
#
function basho_service_start() {
    local commandName=$1
    local serviceName=$2
    local tries=0
    local maxTries=5

    echo -n "Starting ${serviceName}…"
    $commandName start

    until (riak ping | grep "pong" > /dev/null) || ((++tries >= maxTries)) ; do
        echo "Waiting for ${serviceName}…"
        sleep 1
    done

    if ((tries >= maxTries)); then
        echo -e "\nCould not start ${serviceName} after ${tries} attempts…"
        exit 1
    fi

    echo " OK!"
}

#
# @param $1 Command name.
# @param $2 Service name.
#
function basho_service_stop() {
    commandName=$1
    serviceName=$2

    echo -n "Stopping ${serviceName}…"
    $commandName stop > /dev/null
    echo " OK!"
}

#
# @param $1 Admin key.
# @param $2 Admin secret.
#
function riak_cs_update_admin(){
    local key=$1
    local secret=$2
    local riakCsConfigPath='/etc/riak-cs/advanced.config'
    local stanchionConfigPath='/etc/stanchion/advanced.config'

    patchConfig $riakCsConfigPath '\Q{anonymous_user_creation, true}\E' '{anonymous_user_creation, false}'
    patchConfig $riakCsConfigPath '\Q%%{admin_key, null}\E' '{admin_key, "'$key'"}'
    patchConfig $riakCsConfigPath '\Q%%{admin_secret, null}\E' '{admin_secret, "'$secret'"}'
    patchConfig $stanchionConfigPath '\Q%%{admin_key, null}\E' '{admin_key, "'$key'"}'
    patchConfig $stanchionConfigPath '\Q%%{admin_secret, null}\E' '{admin_secret, "'$secret'"}'
}

basho_service_start 'riak' 'Riak'
basho_service_start 'stanchion' 'Stanchion'
basho_service_start 'riak-cs' 'Riak CS'

credentials=$(curl -ks \
    -XPOST 'http://127.0.0.1:8080/riak-cs/user' \
    -H 'Content-Type: application/json' \
    --data '{"email":"admin@s3.amazonaws.dev", "name":"admin"}')

key=$(echo -n $credentials | pcregrep -o '"key_id"\h*:\h*"\K([^"]*)')
secret=$(echo -n $credentials | pcregrep -o '"key_secret"\h*:\h*"\K([^"]*)')

riak_cs_update_admin $key $secret

# Create admin credentials.

cat <<-EOL

	############################################################

	    Riak admin credentials, make note of them, otherwise
	    you will not be able to access your files and data.

	       Key: ${key}
	    Secret: ${secret}

	############################################################

EOL

# Create buckets if the $RIAK_CS_BUCKETS variable is defined.

if [ -v RIAK_CS_BUCKETS ]; then
    echo "Creating Riak CS buckets."

    IFS=$','; for bucket in $RIAK_CS_BUCKETS; do
        riak_cs_bucket_create $key $secret $bucket
    done
fi