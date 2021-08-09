#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/deepin-cd}

shopt -s extglob

fileobjs=()
for version in "$TUNASYNC_WORKING_DIR/"*; do
    if [[ -d "$version" ]]; then
        for file in "$version/"*.iso; do
            url="${file#"$fsprefix"}"
            base="$(basename "$file")"
            size="`du -h "$file"`"
            md5="`grep '\s'"$base"'$' "$version/MD5SUMS" | cut -d' ' -f 1`"
            sha256="`grep '\s'"$base"'$' "$version/SHA256SUMS" | cut -d' ' -f 1`"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url,"size":$size,"md5":$md5,"sha256":$sha256}'\
                --arg ver "$(basename "$version")"\
                --arg base "$base"\
                --arg url "$url"\
                --arg size "$size"\
                --arg md5 "$md5"\
                --arg sha256 "$sha256"`"
            fileobjs=("${fileobjs[@]}" "$fileobj")
        done
    fi
done

jq -nc '[{"name":"Deepin",files:$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
