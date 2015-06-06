#!/usr/bin/env bash

#
# @param $1 Configuration file path.
# @param $2 PCRE regular expression pattern.
# @param $3 Replacement string.
#
function patchConfig() {
    local path=$1
    local pattern=$2
    local substitution=$3

    # In case the provided input is in heredoc format (http://stackoverflow.com/a/4665893/458356).

    while read -r line; do
        substitution+="\n$line"
    done

    perl -i -0pe "s|${pattern}|${substitution}|g" $path
}