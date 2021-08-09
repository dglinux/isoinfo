#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/ubuntukylin-cd}

shopt -s extglob

fileobjs=()
for version in "$TUNASYNC_WORKING_DIR/"*.*; do
    if [[ -d "$version" ]]; then
        for file in "$version/"*.iso; do
            url="${file#"$fsprefix"}"
            size="`du -h "$file"`"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url,"size":$size}'\
                --arg ver "$(basename "$version")"\
                --arg base "$(basename "$file")"\
                --arg size "$size"\
                --arg url "$url"`"
            fileobjs=("${fileobjs[@]}" "$fileobj")
        done
    fi
done

jq -nc '[{"name":"UbuntuKylin",files:$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
