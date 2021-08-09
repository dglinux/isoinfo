#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/ubuntu-releases}

shopt -s extglob

fileobjs=()
readarray -t codenames < <(readlink "$TUNASYNC_WORKING_DIR/"*.* | uniq | tac)
for code in "${codenames[@]}"; do
    version="$TUNASYNC_WORKING_DIR/$code"
    if [[ -d "$version" ]]; then
        for file in "$version/"*.iso; do
            url="${file#"$fsprefix"}"
            base="$(basename "$file")"
            size="`du -h "$file" | cut -f 1`"
            sha256="`grep '*'"$base"'$' "$version/SHA256SUMS" | cut -d' ' -f 1`"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url,"size":$size,"sha256":$sha256}'\
                --arg ver "$code"\
                --arg base "$base"\
                --arg url "$url"\
                --arg size "$size"\
                --arg sha256 "$sha256"`"
            fileobjs=("${fileobjs[@]}" "$fileobj")
        done
    fi
done

jq -nc '[{"name":"Ubuntu","files":$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
