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

toolchain_dir="gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
cross_compiler="${TOOLSET_DIR}/u-boot/${toolchain_dir}/bin/aarch64-linux-gnu-"

info "checking Das U-Boot dependencies"

if $(are_uboot_dependencies_satisfied); then
    info "Das U-Boot dependencies are satisfied"
    uboot_dependencies_satisfied=true
else
    info "Das U-Boot dependencies are not satisfied"
    uboot_dependencies_satisfied=false
fi

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

if ${uboot_dependencies_are_satisfied}; then

    if [ ! -d "${TOOLSET_DIR}/u-boot/boot.scr" ] || [ ! -d "${TOOLSET_DIR}/u-boot/u-boot.bin" ]; then

        if [ ! -d "${TOOLSET_DIR}/u-boot" ]; then
            create_dir "${TOOLSET_DIR}/u-boot"
        fi

        if [ ! -d "${TOOLSET_DIR}/u-boot/u-boot-${UBOOT_VER}" ]; then
            pushd "${TOOLSET_DIR}"
                info "fetching Das U-Boot ${UBOOT_VER} from https://github.com/u-boot/u-boot/archive/"
                wget "${UBOOT_REPO}${UBOOT_VER}.tar.gz" -O "u-boot.tar.xz"
                info "unpacking Das U-Boot archive"
                tar xf "u-boot.tar.xz" -C "${TOOLSET_DIR}/u-boot"
                rm "u-boot.tar.xz"
            popd
        fi

        if [ ! -d "${TOOLSET_DIR}/u-boot/${toolchain_dir}" ]; then
            pushd "${TOOLSET_DIR}/u-boot"
                info "fetching cross-toolchain for building Das U-Boot"
                wget "https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/${toolchain_dir}.tar.xz" -O "${toolchain_dir}.tar.xz"
                info "unpacking cross-toolchain archive"
                tar xf "${toolchain_dir}.tar.xz"
                rm "${toolchain_dir}.tar.xz"
            popd
        fi

    pushd "${TOOLSET_DIR}/u-boot/u-boot-${UBOOT_VER}"
        info "writing configuration for Das U-Boot"
        ARCH=arm CROSS_COMPILE="${cross_compiler}" chrt -i 0 make rpi_3_defconfig
        ARCH=arm CROSS_COMPILE="${cross_compiler}" chrt -i 0 make -j4
        mv u-boot.bin "${TOOLSET_DIR}/u-boot"
        info "generating image for Das U-Boot"
        mkimage -A arm -T script -C none -n "Boot script" -d "${PIEMAN_DIR}"/files/u-boot/boot.cmd "${TOOLSET_DIR}"/u-boot/boot.scr
    popd

    pushd "${TOOLSET_DIR}/u-boot"
        info "cleaning up"
        rm -r "${toolchain_dir}"
        rm -r "u-boot-${UBOOT_VER}"
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
