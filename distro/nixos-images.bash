#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/nixos-images}

shopt -s extglob

fileobjs=()
for version in "$TUNASYNC_WORKING_DIR/"*; do
    if [[ -d "$version" ]]; then
        for file in "$version"/*.iso; do
            ver="$(basename "$version")"
            ver="${ver#nixos-}"
            base="$(basename "$file")"
            url="${file#"$fsprefix"}"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url}'\
                --arg ver "$ver"\
                --arg base "$base"\
                --arg url "$url"`"
            fileobjs=("${fileobjs[@]}" "$fileobj")
        done
    fi
done

jq -nc '[{"name":"NixOS",files:$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
