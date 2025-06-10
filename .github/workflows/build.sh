#!/bin/bash

_API_LIST=({21..27})
_ARCH_LIST=(arm arm64 x86)

function _select_bridge_jar()
{
    local api="$1"
    [ "$api" -le 25 ] \
        && echo "common/XposedBridge.89.jar" \
        || echo "common/XposedBridge.90.jar"
}

function _make_dist_name()
{
    local api="$1"
    local arch="$2"
    echo "xposed-sdk${api}-${arch}.zip"
}

function _package_dists()
{
    local src_dir="$1"
    local dst_dir=$(realpath "$2")
    for api in "${_API_LIST[@]}"
    do
        for arch in "${_ARCH_LIST[@]}"
        do
            local dst_file="${dst_dir}/"$(_make_dist_name "$api" "$arch")
            pushd "$src_dir" > /dev/null
            zip -r "$dst_file" \
                "${api}/${arch}/" \
                "META-INF/" \
                "module.prop" \
                "customize.sh" \
                "post-fs-data.sh"
            zip -j -u "$dst_file" \
                $(_select_bridge_jar "$api")
            popd > /dev/null
        done
    done
}


_package_dists "$@"