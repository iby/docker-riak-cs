#!/usr/bin/env bash

# Make sure we are in the same directory as the script and run relevant scripts in that order.

cd $(dirname $0)

if [ "$1" = 'riak' ]; then
    . functions.sh
    . configuration.sh
    . patch_configuration.sh
    . configure_application.sh

    supervisord --nodaemon --configuration='../configuration/supervisord.conf'
fi