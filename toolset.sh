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

toolchain_dir="gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf"
cross_compiler="${TOOLSET_DIR}/uboot-${UBOOT_VER}/${toolchain_dir}/bin/arm-linux-gnueabihf-"

toolchain_for_mender_dir="gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf"
cross_compiler_for_mender="${TOOLSET_DIR}/mender/${toolchain_for_mender_dir}/bin/arm-linux-gnueabihf-"
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

info "checking Das U-Boot dependencies"

if ! $(are_uboot_dependencies_satisfied) && [[ ! -d "${TOOLSET_DIR}/uboot-${UBOOT_VER}" ]]; then
    fatal "Das U-Boot dependencies are not satisfied"
    exit 1
else
    info "Das U-Boot dependencies are satisfied"
fi

if $(init_installation_if_needed "${TOOLSET_DIR}/apk"); then
    info "fetching apk.static for Alpine Linux ${ALPINE_VER}"
    pushd "${TOOLSET_DIR}"/apk
        create_dir "${ALPINE_VER}"

        addr=http://dl-cdn.alpinelinux.org/alpine/
        apk_tools_version="$(get_apk_tools_version "${ALPINE_VER}")"
        apk_tools_static="apk-tools-static-${apk_tools_version}.apk"
        apk_tools_static_path="${TOOLSET_DIR}/apk/${ALPINE_VER}"

        wget "${addr}/v${ALPINE_VER}/main/armhf/${apk_tools_static}" -O "${apk_tools_static_path}/${apk_tools_static}"

        tar -xzf "${apk_tools_static_path}/${apk_tools_static}" -C "${apk_tools_static_path}"

        mv "${apk_tools_static_path}/sbin/apk.static" "${apk_tools_static_path}"

        finalise_installation \
            "${apk_tools_static_path}/${apk_tools_static}" \
            "${apk_tools_static_path}/sbin"
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

if ${mender_dependencies_are_satisfied} && $(init_installation_if_needed "${TOOLSET_DIR}/mender"); then
    pushd "${TOOLSET_DIR}/mender"
        info "downloading inventory & identity scripts"
        wget -q -O mender-device-identity "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-device-identity
        wget -q -O mender-inventory-bootloader-integration "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-bootloader-integration
        wget -q -O mender-inventory-hostinfo "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-hostinfo
        wget -q -O mender-inventory-network "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-network
        wget -q -O mender-inventory-os "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-os
        wget -q -O mender-inventory-rootfs-type "${MENDER_CLIENT_REPO}"/"${MENDER_CLIENT_REVISION}"/support/mender-inventory-rootfs-type

        info "fetching cross-toolchain for building Das U-Boot (Mender flavour) and Mender client"
        wget "https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/${toolchain_for_mender_dir}.tar.xz" -O "${toolchain_for_mender_dir}.tar.xz"

        info "unpacking archive with toolchain for building Das U-Boot (Mender flavour)"
        tar xJf "${toolchain_for_mender_dir}.tar.xz"
        rm "${toolchain_for_mender_dir}.tar.xz"

        info "fetching Das U-Boot (Mender flavour) from https://github.com/mendersoftware/uboot-mender.git"
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
        info "building Das U-Boot (Mender flavour)"

        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make --quiet distclean
        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make rpi_3_32b_defconfig
        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make PYTHON=python -j $(number_of_cores)
        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make envtools -j $(number_of_cores)

        cp "u-boot.bin" "${TOOLSET_DIR}/mender"
        cp tools/env/fw_printenv "${TOOLSET_DIR}/mender"

        info "generating image for Das U-Boot (Mender flavour)"
        "${uboot_tools}"/mkimage -A arm -T script -C none -n "Boot script" -d "${PIEMAN_DIR}"/files/mender/boot.cmd "${TOOLSET_DIR}"/mender/boot.scr
    popd

    pushd "${mendersoftware_dir}"/mender
        info "building Mender client"

        env CGO_ENABLED=1 \
            CC="${cross_compiler_for_mender}"gcc \
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

    pushd "${TOOLSET_DIR}/mender"
        finalise_installation "${toolchain_for_mender_dir}" client uboot-mender
    popd
fi

if $(init_installation_if_needed "${TOOLSET_DIR}/uboot-${UBOOT_VER}"); then
    pushd "${TOOLSET_DIR}/uboot-${UBOOT_VER}"
        info "fetching cross-toolchain for building Das U-Boot"
        wget "https://releases.linaro.org/components/toolchain/binaries/7.4-2019.02/arm-linux-gnueabihf/${toolchain_dir}.tar.xz" -O "${toolchain_dir}.tar.xz"

        info "unpacking archive with toolchain for building Das U-Boot"
        tar xJf "${toolchain_dir}.tar.xz"
        rm "${toolchain_dir}.tar.xz"

        info "fetching Das U-Boot ${UBOOT_VER} from ${UBOOT_URL}"
        git clone --depth=1 -b "v${UBOOT_VER}" https://github.com/u-boot/u-boot.git "u-boot-${UBOOT_VER}"
    popd

    pushd "${TOOLSET_DIR}/uboot-${UBOOT_VER}/u-boot-${UBOOT_VER}"
        info "building Das U-Boot"

        ARCH=arm CROSS_COMPILE="${cross_compiler}" make orangepi_pc_plus_defconfig

        # The host system may have both Python 2 and 3 installed. U-Boot
        # depends on Python 2, so it's necessary to specify it explicitly via
        # the PYTHON variable.
        ARCH=arm CROSS_COMPILE="${cross_compiler}" PYTHON=python make -j $(number_of_cores)

        cp tools/mkimage "${TOOLSET_DIR}/uboot-${UBOOT_VER}"
        cp u-boot-sunxi-with-spl.bin "${TOOLSET_DIR}/uboot-${UBOOT_VER}"
    popd

    pushd "${TOOLSET_DIR}/uboot-${UBOOT_VER}"
        finalise_installation "${toolchain_dir}" "u-boot-${UBOOT_VER}" uboot-env
    popd
fi

# Correct ownership if needed
pieman_dir_ownership="$(get_ownership "${PIEMAN_DIR}")"
if [ "$(get_ownership "${TOOLSET_DIR}")" != "${pieman_dir_ownership}" ]; then
    info "correcting ownership for ${TOOLSET_DIR}"
    chown -R "${pieman_dir_ownership}" "${TOOLSET_DIR}"
fi

if ${PREPARE_ONLY_TOOLSET}; then
    success "exiting since PREPARE_ONLY_TOOLSET is set to true"

    exit 0
fi
