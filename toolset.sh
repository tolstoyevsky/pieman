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

toolchain_dir="gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf"
cross_compiler="${TOOLSET_DIR}/mender/${toolchain_dir}/bin/arm-linux-gnueabihf-"
uboot_tools="${TOOLSET_DIR}/mender/uboot-mender/tools"
mendersoftware_dir="${TOOLSET_DIR}"/mender/client/src/mender/vendor/github.com/mendersoftware

info "checking Mender dependencies"

if $(are_mender_dependencies_satisfied); then
    info "Mender dependencies are satisfied"
    mender_dependencies_are_satisfied=true
else
    info "Mender dependencies are not satisfied"
    mender_dependencies_are_satisfied=false
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

if [ ! -d "${TOOLSET_DIR}/mender" ] && ${mender_dependencies_are_satisfied}; then
    create_dir "${TOOLSET_DIR}/mender"

    pushd "${TOOLSET_DIR}/mender"
        info "downloading inventory & identity scripts"
        wget -q -O mender-device-identity "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-device-identity
        wget -q -O mender-inventory-bootloader-integration "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-bootloader-integration
        wget -q -O mender-inventory-hostinfo "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-hostinfo
        wget -q -O mender-inventory-network "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-network
        wget -q -O mender-inventory-os "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-os
        wget -q -O mender-inventory-rootfs-type "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-rootfs-type

        info "fetching cross-toolchain for building Das U-Boot and Mender client"
        wget "https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/${toolchain_dir}.tar.xz" -O "${toolchain_dir}.tar.xz"

        info "unpacking cross-toolchain archive"
        tar xJf "${toolchain_dir}.tar.xz"
        rm "${toolchain_dir}.tar.xz"

        info "fetching Das U-Boot from https://github.com/mendersoftware/uboot-mender.git"
        git clone https://github.com/mendersoftware/uboot-mender.git -b "${UBOOT_MENDOR_BRANCH}"
        git -C "uboot-mender" checkout "${UBOOT_MENDOR_COMMIT}"

        mkdir -p "${mendersoftware_dir}"

        info "fetching Mender client from https://github.com/mendersoftware/mender.git"
        git clone https://github.com/mendersoftware/mender.git "${mendersoftware_dir}"/mender
        git -C "${mendersoftware_dir}"/mender checkout "${MENDER_CLIENT_VER}"

        info "fetching Mender Artifacts Library from https://github.com/mendersoftware/mender-artifact.git"
        git clone https://github.com/mendersoftware/mender-artifact.git "${mendersoftware_dir}"/mender-artifact
        git -C "${mendersoftware_dir}"/mender-artifact checkout "${MENDER_ARTIFACT_VER}"
    popd

    pushd "${TOOLSET_DIR}/mender/uboot-mender"
        info "building Das U-Boot"

        ARCH=arm CROSS_COMPILE="${cross_compiler}" make --quiet distclean
        ARCH=arm CROSS_COMPILE="${cross_compiler}" make rpi_3_32b_defconfig
        ARCH=arm CROSS_COMPILE="${cross_compiler}" make
        ARCH=arm CROSS_COMPILE="${cross_compiler}" make envtools

        cp "u-boot.bin" "${TOOLSET_DIR}/mender"
        cp tools/env/fw_printenv "${TOOLSET_DIR}/mender"

        info "generating image for Das U-Boot"
        "${uboot_tools}"/mkimage -A arm -T script -C none -n "Boot script" -d "${PIEMAN_DIR}"/files/mender/boot.cmd "${TOOLSET_DIR}"/mender/boot.scr
    popd

    pushd "${mendersoftware_dir}"/mender
        info "building Mender client"

        env CGO_ENABLED=1 \
            CC="${cross_compiler}"gcc \
            GOARCH=arm \
            GOOS=linux \
            GOPATH="${TOOLSET_DIR}"/mender/client make build

        cp mender "${TOOLSET_DIR}"/mender
    popd

    pushd "${mendersoftware_dir}"/mender-artifact
        info "building Mender Artifacts Library"

        env GOPATH="${TOOLSET_DIR}"/mender/client make build

        cp mender-artifact "${TOOLSET_DIR}"/mender
    popd

    # Cleanup
    pushd "${TOOLSET_DIR}/mender"
        rm -r "${toolchain_dir}"
        rm -r "client"
        rm -r "uboot-mender"
    popd
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
