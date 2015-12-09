#!/usr/bin/env bash

# Make sure we are in the same directory as the script and run relevant scripts in that order.

cd $(dirname $0)

. functions.sh
. configuration.sh
. install_dependencies.sh
. patch_configuration.sh

echo -n 'Moving entrypoint scripts…'
mkdir --parent '/entrypoint/configuration'
mkdir --parent '/entrypoint/script'
mv './entrypoint.sh' '/'
mv '../configuration/'* '/entrypoint/configuration'
mv './configure_application.sh' '/entrypoint/script'
mv './functions.sh' '/entrypoint/script'
echo ' OK!'

echo -n 'Cleaning up container.'
rm -rf \
    '/docker' \
    '/tmp/'* \
    '/var/tmp/'*
echo ' OK!'

echo 'Bye-bye!'