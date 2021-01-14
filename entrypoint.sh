#!/bin/bash

set -e -o pipefail

PACKAGE_LOCATION="${1}"
CLOUDSMITH_REPO="${2}"
CLOUDSMITH_USERNAME="${3}"
export CLOUDSMITH_API_KEY="${4}"

cloudsmith_push_args=(--error-retry-max 30 --republish)

# required to make python 3 work with cloudsmith script
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

function upload_rpm {
    sync=$1
    distro=$2
    pkg_fullpath=$3
    pkg_filename="$(basename "${pkg_fullpath}")"
    rev_filename=$(echo "${pkg_filename}" | rev)

    pkg_name=$(echo "${rev_filename}" | cut -d '-' -f3- | rev)
    pkg_version=$(echo "${rev_filename}" | cut -d '-' -f1-2 | rev | cut -d '.' -f1-3)
    pkg_arch=$(echo "${rev_filename}" | cut -d '.' -f2 | rev)
    pkg_rel=$(echo "${rev_filename}" | cut -d '.' -f3 | rev)
    release_ver="${pkg_rel:2}"

    sync_arg=""
    if [ "${sync}" == "nosync" ]; then
        sync_arg="--no-wait-for-sync"
    fi

    cloudsmith push rpm ${sync_arg} "${cloudsmith_push_args[@]}" "${CLOUDSMITH_REPO}/${distro}/${release_ver}" "${pkg_fullpath}"
}

function upload_deb {
    sync=$1
    distro=$2
    release=$3
    pkg_fullpath=$4

    sync_arg=""
    if [ "${sync}" == "nosync" ]; then
        sync_arg="--no-wait-for-sync"
    fi

    cloudsmith push deb "${sync_arg}" "${cloudsmith_push_args[@]}" "${CLOUDSMITH_REPO}/${distro}/${release}" "${pkg_fullpath}"
}

function cloudsmith_upload {
    sync=$1
    distro=$2
    release=$3
    pkg_fullpath=$4

    if [[ ${distro} =~ centos ]]; then
        upload_rpm "${sync}" "centos" "${pkg_fullpath}"
    elif [[ ${distro} =~ fedora ]]; then
        upload_rpm "${sync}" "fedora" "${pkg_fullpath}"
    else
        upload_deb "${sync}" "${distro}" "${release}" "${pkg_fullpath}"
    fi
}

pip3 install --upgrade cloudsmith-cli


while IFS= read -r -d '' path; do
    IFS=_ read -r distro release <<< "$(basename "${path}")"

    pkgs=()

    while IFS= read -r -d '' pkg; do
        pkgs+=("${pkg}")
    done <    <(find "${path}" -maxdepth 1 -type f -print0)

    i=0
    last=$((${#pkgs[@]}-1))
    for pkg in "${pkgs[@]}"; do
        if [ ${i} -eq ${last} ]; then
            # wait for final package upload for each distro release to synchronise
            echo cloudsmith_upload "sync" "${distro}" "${release}" "${pkg}"
        else
            echo cloudsmith_upload "nosync" "${distro}" "${release}" "${pkg}"
        fi
        ((i++))
    done
done <   <(find "${PACKAGE_LOCATION}" -mindepth 1 -maxdepth 1 -type d -print0)
