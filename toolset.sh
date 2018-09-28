# Copyright (C) 2018 Evgeny Golyshev <eugulixes@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [ ! -d "${TOOLSET_DIR}/apk/${ALPINE_VER}" ]; then
    create_dir "${TOOLSET_DIR}/apk/${ALPINE_VER}"

    info "fetching apk.static for Alpine Linux ${ALPINE_VER}"
    pushd "${TOOLSET_DIR}"/apk
        addr=http://dl-cdn.alpinelinux.org/alpine/
        apk_tools_version="$(get_apk_tools_version "${ALPINE_VER}")"
        apk_tools_static="apk-tools-static-${apk_tools_version}.apk"
        apk_tools_static_path="${TOOLSET_DIR}/apk/${ALPINE_VER}"

        wget "${addr}/v${ALPINE_VER}/main/armhf/${apk_tools_static}" -O "${apk_tools_static_path}/${apk_tools_static}"

        tar -xzf "${apk_tools_static_path}/${apk_tools_static}" -C "${apk_tools_static_path}"

        mv "${apk_tools_static_path}/sbin/apk.static" "${apk_tools_static_path}"

        rm    "${apk_tools_static_path}/${apk_tools_static}"
        rm -r "${apk_tools_static_path}/sbin"
    popd
fi

if [ ! -d "${TOOLSET_DIR}/debootstrap" ]; then
    info "fetching debootstrap ${DEBOOTSTRAP_VER}"
    pushd "${TOOLSET_DIR}"
        git clone https://salsa.debian.org/installer-team/debootstrap.git

        git -C debootstrap checkout "${DEBOOTSTRAP_VER}"
    popd
else
    info "checking if the debootstrap version is equal to or higher ${DEBOOTSTRAP_VER}"

    if ! is_debootstrap_uptodate; then
        pushd "${TOOLSET_DIR}"/debootstrap
            info "upgrading debootstrap to ${DEBOOTSTRAP_VER}"

            git checkout master

            git pull

            git checkout ${DEBOOTSTRAP_VER}
        popd
    fi
fi

# Correct ownership if needed
pieman_dir_ownership="$(get_ownership "${PIEMAN_DIR}")"
if [ "$(get_ownership "${TOOLSET_DIR}")" != "${pieman_dir_ownership}" ]; then
    info "correcting ownership for ${TOOLSET_DIR}"
    chown -R "${pieman_dir_ownership}" "${TOOLSET_DIR}"
fi

if ${PREPARE_ONLY_TOOLSET}; then
    info "exiting since PREPARE_ONLY_TOOLSET is set to true"

    exit 0
fi
