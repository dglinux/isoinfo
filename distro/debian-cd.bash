#!/usr/bin/env bash
LIVE_ARCHS=(amd64 i386)
ARCHS=(amd64 i386 armhf arm64 armhf mips mipsel mips64el s390x)
fsprefix=${TUNASYNC_WORKING_DIR%/debian-cd}

shopt -s extglob

get_fileobj() {
    local version="$1" arch="$2" file="$3"
    local url="${file#"$fsprefix"}"
    local ver="$(basename "$version")"
    local dir="$(dirname "$file")"
    local base="$(basename "$file")"
    local md5="`grep '\s'"$base"'$' "$dir/MD5SUMS" | cut -d' ' -f 1`"
    local sha1="`grep '\s'"$base"'$' "$dir/SHA1SUMS" | cut -d' ' -f 1`"
    local sha256="`grep '\s'"$base"'$' "$dir/SHA256SUMS" | cut -d' ' -f 1`"
    local sha512="`grep '\s'"$base"'$' "$dir/SHA512SUMS" | cut -d' ' -f 1`"
    jq -nc '{"ver":$ver,"base":$base,"url":$url,"md5":$md5,"sha1":$sha1,"sha256":$sha256,"sha512":$sha512}'\
        --arg ver "$ver-$arch"\
        --arg base "$base"\
        --arg url "${url}"\
        --arg md5 "$md5"\
        --arg sha1 "$sha1"\
        --arg sha256 "$sha256"\
        --arg sha512 "$sha512"
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
            for file in "$version/$arch/iso-cd/"*.iso "$version/$arch/iso-dvd/"*.iso; do
                fileobj="`get_fileobj "$version" "$arch" "$file"`"
                cd_files=("${cd_files[@]}" "$fileobj")
            done
        done
    fi
done

latest_livecd="`readlink $TUNASYNC_WORKING_DIR/current-live`"
latest_cd="`readlink $TUNASYNC_WORKING_DIR/current`"
livecd="`jq -nc '{"name":"Debian Live CD",files:$ARGS.positional,latest:$latest}'\
    --jsonargs "${livecd_files[@]}"\
    --arg latest "$latest_livecd"`"
cdimages="`jq -nc '{"name":"Debian",files:$ARGS.positional,latest:$latest}'\
    --jsonargs "${cd_files[@]}"\
    --arg latest "$latest_cd"`"
jq -nc '[$livecd,$cdimages]' --argjson livecd "$livecd" --argjson cdimages "$cdimages"
