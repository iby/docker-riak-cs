#!/usr/bin/env bash

echo "Updating existing and installing required packages."

# Update apt-get and install the necessary dependencies.

apt-get -qq update
apt-get -qq install --yes --no-install-recommends \
    adduser \
    curl \
    logrotate \
    openssl \
    pcregrep \
    sudo \
    supervisor

function download(){
    path=$1
    url=$2

    # We may get ssl issues because using curl from container, we want to ignore
    # them, but if it fails, we don't need to carry on.

    curl --fail --insecure --location --progress-bar --output "${path}" "${url}"
}

echo "Downloading Riak:"
download "riak_${RIAK_VERSION}.deb" "https://packagecloud.io/basho/riak/packages/debian/${DEBIAN_VERSION}/riak_${RIAK_VERSION}-1_amd64.deb/download"

echo "Downloading Riak-CS:"
download "riak_cs_${RIAK_CS_VERSION}.deb" "https://packagecloud.io/basho/riak-cs/packages/debian/${DEBIAN_VERSION}/riak-cs_${RIAK_CS_VERSION}-1_amd64.deb/download"

echo "Downloading Stanchion:"
download "stanchion_${STANCHION_VERSION}.deb" "https://packagecloud.io/basho/stanchion/packages/debian/${DEBIAN_VERSION}/stanchion_${STANCHION_VERSION}-1_amd64.deb/download"

echo "Installing Riak, Riak-CS and Stanchion."

dpkg -i "riak_${RIAK_VERSION}.deb"
dpkg -i "riak_cs_${RIAK_CS_VERSION}.deb"
dpkg -i "stanchion_${STANCHION_VERSION}.deb"

rm -rf /var/lib/apt/lists/*
rm "riak_${RIAK_VERSION}.deb"
rm "riak_cs_${RIAK_CS_VERSION}.deb"
rm "stanchion_${STANCHION_VERSION}.deb"