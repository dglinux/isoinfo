#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/ubuntu-releases}

shopt -s extglob

get_version() {
    local IFS="-" splitted=()
    read -ra splitted <<< "$1"
    echo "${splitted[1]}"
}

fileobjs=()
for file in "$TUNASYNC_WORKING_DIR/.pool/"*.iso; do
    base="$(basename "$file")"
    version="`get_version "$base"`"
    url="${file#"$fsprefix"}"
    fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url}'\
        --arg ver "$version"\
        --arg base "$base"\
        --arg url "$url"`"
    fileobjs=("${fileobjs[@]}" "$fileobj")
done

jq -nc '[{"name":"Ubuntu",files:$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
