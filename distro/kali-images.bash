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
            sha1="`grep '\s'"$base"'$' "$version/SHA1SUMS" | cut -d' ' -f 1`"
            sha256="`grep '\s'"$base"'$' "$version/SHA256SUMS" | cut -d' ' -f 1`"
            fileobj="`jq -nc '{"ver":$ver,"base":$base,"url":$url,"sha1":$sha1,"sha256":$sha256}'\
                --arg ver "$ver"\
                --arg base "$base"\
                --arg url "$url"\
                --arg sha1 "$sha1"\
                --arg sha256 "$sha256"`"
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

latest="`readlink $TUNASYNC_WORKING_DIR/current`"
latest="${latest#kali-}"
livecd="`jq -nc '{"name":"Kali Live CD","files":$ARGS.positional,"latest":$latest}' --jsonargs "${livecd_files[@]}" --arg latest "$latest"`"
cdimages="`jq -nc '{"name":"Kali Installer","files":$ARGS.positional,"latest":$latest}' --jsonargs "${cd_files[@]}" --arg latest "$latest"`"
jq -nc '[$livecd,$cdimages]' --argjson livecd "$livecd" --argjson cdimages "$cdimages"
