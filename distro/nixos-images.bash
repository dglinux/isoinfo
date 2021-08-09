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
            size="`du -h "$file" | cut -f 1`"
            sha256="`cut -d' ' -f 1 "$version/$base.sha256"`"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url,"size":$size,"sha256":$sha256}'\
                --arg ver "$ver"\
                --arg base "$base"\
                --arg url "$url"\
                --arg size "$size"\
                --arg sha256 "$sha256"`"
            fileobjs=("${fileobjs[@]}" "$fileobj")
        done
    fi
done

jq -nc '[{"name":"NixOS",files:$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
