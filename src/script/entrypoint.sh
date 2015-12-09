#!/usr/bin/env bash

# Make sure we are in the same directory as the script and run relevant scripts in that order.

cd $(dirname $0)

if [ "$1" = 'riak' ]; then
    . '/entrypoint/script/functions.sh'
    . '/entrypoint/script/configure_application.sh'

    supervisord --nodaemon --configuration='/entrypoint/configuration/supervisord.conf'
else
    exec "${@}"
fi