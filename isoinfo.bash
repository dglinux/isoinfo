#!/usr/bin/env bash

here="$(dirname $0)"
[[ -d ~/.isoinfo ]] || mkdir -p ~/.isoinfo

# isoinfo.bash --all /media/hdds/mirrors/repos
if [[ "$1" == --all && "$2" ]]; then
    for script in "$here/distro/"*.bash; do
        distro="$(basename "$script")"
        distro="${distro%.bash}"
        export TUNASYNC_WORKING_DIR="$2/$distro"
        "$script" > ~/.isoinfo/"$distro".json
    done
else
    distro="$(basename "$TUNASYNC_WORKING_DIR")"
    script="$here/distro/$distro.bash"
    "$script" > ~/.isoinfo/"$distro".json
fi

jq -sc "[.[][]]" ~/.isoinfo/* > ~/isoinfo.json

