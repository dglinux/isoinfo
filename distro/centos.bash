#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/centos}

shopt -s extglob

fileobjs=()
IFS=$'\n' readarray -t isos < <(find "$TUNASYNC_WORKING_DIR/"*/isos/ -name '*.iso' )
for file in "${isos[@]}"; do
    url="${file#"$fsprefix"}"
    version="`cut -d'/' -f 3 <<< "$url"`"
    # Some dirs are symlinks
    if [[ ! -L "$TUNASYNC_WORKING_DIR/$version" ]]; then
        arch="`cut -d'/' -f 5 <<< "$url"`"
        base="`basename "$file"`"
        fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url}'\
            --arg ver "$version-$arch"\
            --arg base "$base"\
            --arg url "$url"`"
        fileobjs=("${fileobjs[@]}" "$fileobj")
    fi
done

jq -nc '[{"name":"CentOS","files":$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
