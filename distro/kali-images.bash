#!/usr/bin/env bash
fsprefix=${TUNASYNC_WORKING_DIR%/kali-images}

shopt -s extglob

livecd_files=()
cd_files=()
for version in "$TUNASYNC_WORKING_DIR/"kali-*; do
    if [[ -d "$version" ]]; then
        for file in "$version/"*.iso; do
            ver="$(basename "$version")"
            ver="${ver#kali-}"
            url="${file#"$fsprefix"}"
            base="$(basename "$file")"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url}'\
                --arg ver "$ver"\
                --arg base "$base"\
                --arg url "$url"`"
            case "$base" in
                *installer*)
                    cd_files=("${cd_files[@]}" "$fileobj")
                    ;;
                *live*)
                    livecd_files=("${livecd_files[@]}" "$fileobj")
                    ;;
            esac
        done
    fi
done

livecd="`jq -nc '{"name":"Kali Live CD",files:$ARGS.positional}' --jsonargs "${livecd_files[@]}"`"
cdimages="`jq -nc '{"name":"Kali Installer",files:$ARGS.positional}' --jsonargs "${cd_files[@]}"`"
jq -nc '[$livecd,$cdimages]' --argjson livecd "$livecd" --argjson cdimages "$cdimages"
