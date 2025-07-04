#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

set -e

get_canonical_version()
{
    IFS=.
    set -- $1
    echo $((10000 * $1 + 100 * ${2:-0} + ${3:-0}))
}

orig_args="$@"

IFS='
'
set -- $(LC_ALL=C "$@" --version)

IFS=' '

version_str=""

# First try to find LLD version
for word in "$@"; do
    if [ "$prev" = "LLD" ]; then
        version_str=$word
        break
    fi
    prev=$word
done

# If no LLD found, try to find 'Version' (Snapdragon ld.qcld)
if [ -z "$version_str" ]; then
    prev=""
    for word in "$@"; do
        if [ "$prev" = "Version" ]; then
            version_str=$word
            break
        fi
        prev=$word
    done
fi

if [ -n "$version_str" ]; then
    echo $(get_canonical_version ${version_str%-*})
else
    echo 0
fi

