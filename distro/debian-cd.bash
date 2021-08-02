#!/usr/bin/env bash
LIVE_ARCHS=(amd64 i386)
ARCHS=(amd64 i386 armhf arm64 armhf mips mipsel mips64el s390x)
fsprefix=${TUNASYNC_WORKING_DIR%/debian-cd}

shopt -s extglob

get_fileobj() {
    local version="$1" arch="$2" file="$3"
    local url="${file#"$fsprefix"}"
    jq -nc '{"ver":$ver,"base":$base,"url":$url}'\
        --arg ver "$(basename "$version")-$arch"\
        --arg base "$(basename "$file")"\
        --arg url "${url}"
}

# Live CD
livecd_files=()
for version in "$TUNASYNC_WORKING_DIR/"*.*.*-live; do
    if [[ -d "$version" ]]; then
        for arch in "${LIVE_ARCHS[@]}"; do
            for file in "$version/$arch/iso-hybrid"/*.iso; do
                fileobj="`get_fileobj "$version" "$arch" "$file"`"
                livecd_files=("${livecd_files[@]}" "$fileobj")
            done
        done
    fi
done

# Installation media
cd_files=()
for version in "$TUNASYNC_WORKING_DIR/"*.*.!(*-live); do
    if [[ -d "$version" ]]; then
        for arch in "${ARCHS[@]}"; do
            for file in "$version/$arch/iso-cd/"*.iso; do
                fileobj="`get_fileobj "$version" "$arch" "$file"`"
                cd_files=("${cd_files[@]}" "$fileobj")
            done
            for file in "$version/$arch/iso-dvd/"*.iso; do
                fileobj="`get_fileobj "$version" "$arch" "$file"`"
                cd_files=("${cd_files[@]}" "$fileobj")
            done
        done
    fi
done

livecd="`jq -nc '{"name":"Debian Live CD",files:$ARGS.positional}' --jsonargs "${livecd_files[@]}"`"
cdimages="`jq -nc '{"name":"Debian",files:$ARGS.positional}' --jsonargs "${cd_files[@]}"`"
jq -nc '[$livecd,$cdimages]' --argjson livecd "$livecd" --argjson cdimages "$cdimages"
