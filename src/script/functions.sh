#!/usr/bin/env bash

#
# Shared functions that are used by other scripts.
#

#
# Uses perl regular expressions to replace the given pattern with a substitution.
#
# ```
# patchConfig foo.config '\Qbar\E' 'baz'
# ```
#
# @param $1 Configuration file path.
# @param $2 PCRE regular expression pattern.
# @param $3 Replacement string.
#
function patchConfig() {
    local path=$1
    local pattern=$2
    local substitution=$3

    # Normalise substitution string if it's in heredoc format, http://stackoverflow.com/a/4665893/458356

    while read -r line; do
        substitution+="\n$line"
    done

    perl -i -0pe "s|${pattern}|${substitution}|g" $path
}