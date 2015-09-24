#!/usr/bin/env bash

echo "Updating existing and installing required packages."

# Update apt-get and install the necessary dependencies.

apt-get -qq update
apt-get -qq upgrade --yes
apt-get -qq install --yes --no-install-recommends \
    adduser \
    curl \
    logrotate \
    openssl \
    pcregrep \
    sudo \
    supervisor


echo "Downloading Riak:"
curl -# -L -o "riak_${RIAK_VERSION}.deb" "http://s3.amazonaws.com/downloads.basho.com/riak/"$(echo $RIAK_VERSION | pcregrep -o "^\d+\.\d+")"/${RIAK_VERSION}/debian/7/riak_${RIAK_VERSION}-1_amd64.deb"

echo "Downloading Riak-CS:"
curl -# -L -o "riak-cs_${RIAK_CS_VERSION}.deb" "http://s3.amazonaws.com/downloads.basho.com/riak-cs/"$(echo $RIAK_CS_VERSION | pcregrep -o "^\d+\.\d+")"/${RIAK_CS_VERSION}/debian/7/riak-cs_${RIAK_CS_VERSION}-1_amd64.deb"

echo "Downloading Stanchion:"
curl -# -L -o "stanchion_${STANCHION_VERSION}.deb" "http://s3.amazonaws.com/downloads.basho.com/stanchion/"$(echo $STANCHION_VERSION | pcregrep -o "^\d+\.\d+")"/${STANCHION_VERSION}/debian/7/stanchion_${STANCHION_VERSION}-1_amd64.deb"

echo "Installing Riak, Riak-CS and Stanchion."

dpkg -i "riak_${RIAK_VERSION}.deb"
dpkg -i "riak-cs_${RIAK_CS_VERSION}.deb"
dpkg -i "stanchion_${STANCHION_VERSION}.deb"

rm -rf /var/lib/apt/lists/*
rm "riak_${RIAK_VERSION}.deb"
rm "riak-cs_${RIAK_CS_VERSION}.deb"
rm "stanchion_${STANCHION_VERSION}.deb"