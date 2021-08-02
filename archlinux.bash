#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/archlinux}
fileobjs=()

listfiles() {
    local d
    for d in "$TUNASYNC_WORKING_DIR/iso/"*; do
        local base="`basename "$d"`"
        if [[ -d "$d" && "$base" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
            local isos=("$d/"*.iso)
            for iso in "${isos[@]}"; do
                if [[ -f "$iso" ]]; then
                    local url=${iso#"$fsprefix"}
                    local basefile="`basename "$iso"`"
                    fileobjs=(
                        "${fileobjs[@]}"
                        "`jq -nc '{"ver":$ver,"base":$base,"url":$url}'\
                            --arg ver "$base"\
                            --arg url "$url"\
                            --arg base "$basefile"`"
                    )
                fi
            done
        fi
    done
}

listfiles
#for i in "${fileobjs[@]}"; do echo $i; done
jq -nc '[{"name":"Arch Linux",files:$ARGS.positional}]' --jsonargs "${fileobjs[@]}"
