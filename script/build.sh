#!/usr/bin/env bash

# Make sure we are in the same directory as the script and run relevant scripts in that order.

cd $(dirname $0)

. functions.sh
. configuration.sh
. install_dependencies.sh
. patch_configuration.sh

echo 'Cleaning up container.'

rm -rf /tmp/*
rm -rf /var/tmp/*

echo 'Bye-bye!'