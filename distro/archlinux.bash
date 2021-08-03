#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/archlinux}
fileobjs=()

listfiles() {
    local version
    for version in "$TUNASYNC_WORKING_DIR/iso/"*; do
        local ver="`basename "$version"`"
        if [[ -d "$version" && "$ver" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
            local isos=("$version/"*.iso)
            for iso in "${isos[@]}"; do
                if [[ -f "$iso" ]]; then
                    local url=${iso#"$fsprefix"}
                    local base="`basename "$iso"`"
                    local sha1="`grep '\s'"$base"'$' "$version/sha1sums.txt" | cut -d' ' -f 1`"
                    local md5="`grep '\s'"$base"'$' "$version/md5sums.txt" | cut -d' ' -f 1`"
                    local fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url,"sha1":$sha1,"md5":$md5}'\
                        --arg ver "$ver"\
                        --arg url "$url"\
                        --arg base "$base"\
                        --arg sha1 "$sha1"\
                        --arg md5 "$md5"`"
                    fileobjs=("${fileobjs[@]}" "$fileobj")
                fi
            done
        fi
    done
}

listfiles
latest="`readlink "$TUNASYNC_WORKING_DIR/iso/latest"`"
jq -nc '[{"name":"Arch Linux","files":$ARGS.positional,"latest":$latest}]' --jsonargs "${fileobjs[@]}" --arg latest "$latest"
