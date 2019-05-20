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

dir_with_32bit_toolchain="gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf"
cross_compiler_32bit="${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}/${dir_with_32bit_toolchain}/bin/arm-linux-gnueabihf-"

dir_with_64bit_toolchain="gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu"
cross_compiler_64bit="${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}/${dir_with_64bit_toolchain}/bin/aarch64-linux-gnu-"

toolchain_for_mender_dir="gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf"
cross_compiler_for_mender="${TOOLSET_FULL_PATH}/mender/${toolchain_for_mender_dir}/bin/arm-linux-gnueabihf-"
uboot_tools="${TOOLSET_FULL_PATH}/mender/uboot-mender/tools"
mendersoftware_dir="${TOOLSET_FULL_PATH}"/mender/client/src/mender/vendor/github.com/mendersoftware

info "checking Mender dependencies"

if $(are_mender_dependencies_satisfied); then
    info "Mender dependencies are satisfied"
    mender_dependencies_are_satisfied=true
else
    info "Mender dependencies are not satisfied"
    mender_dependencies_are_satisfied=false
fi

info "checking Das U-Boot dependencies"

if ! $(are_uboot_dependencies_satisfied) && [[ ! -d "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}" ]]; then
    fatal "Das U-Boot dependencies are not satisfied"
    exit 1
else
    info "Das U-Boot dependencies are satisfied"
fi

if $(init_installation_if_needed "${TOOLSET_FULL_PATH}/qemu-user-static"); then
    info "fetching qemu-user-static"
    pushd "${TOOLSET_FULL_PATH}/qemu-user-static"
        get_qemu_emulation_binary

        finalise_installation
    popd
fi

if $(init_installation_if_needed "${TOOLSET_FULL_PATH}/apk"); then
    info "fetching apk.static for Alpine Linux ${ALPINE_VER}"
    pushd "${TOOLSET_FULL_PATH}"/apk
        create_dir "${ALPINE_VER}"

        get_apk_static 3.9 armhf
        get_apk_static 3.9 aarch64

        finalise_installation
    popd
fi

if [ ! -d "${TOOLSET_FULL_PATH}/debootstrap" ]; then
    info "fetching debootstrap ${DEBOOTSTRAP_VER}"
    pushd "${TOOLSET_FULL_PATH}"
        git clone https://salsa.debian.org/installer-team/debootstrap.git

        git -C debootstrap checkout "${DEBOOTSTRAP_VER}"
    popd
else
    info "checking if the debootstrap version is equal to or higher ${DEBOOTSTRAP_VER}"

    if ! is_debootstrap_uptodate; then
        pushd "${TOOLSET_FULL_PATH}"/debootstrap
            info "upgrading debootstrap to ${DEBOOTSTRAP_VER}"

            git checkout master

            git pull

            git checkout ${DEBOOTSTRAP_VER}
        popd
    fi
fi

if ${mender_dependencies_are_satisfied} && $(init_installation_if_needed "${TOOLSET_FULL_PATH}/mender"); then
    pushd "${TOOLSET_FULL_PATH}/mender"
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
        git clone https://github.com/mendersoftware/uboot-mender.git -b "${UBOOT_MENDER_BRANCH}"
        git -C "uboot-mender" checkout "${UBOOT_MENDER_COMMIT}"

        mkdir -p "${mendersoftware_dir}"

        info "fetching Mender client from https://github.com/mendersoftware/mender.git"
        git clone https://github.com/mendersoftware/mender.git "${mendersoftware_dir}"/mender
        git -C "${mendersoftware_dir}"/mender checkout "${MENDER_CLIENT_VER}"

        info "fetching Mender Artifacts Library from https://github.com/mendersoftware/mender-artifact.git"
        git clone https://github.com/mendersoftware/mender-artifact.git "${mendersoftware_dir}"/mender-artifact
        git -C "${mendersoftware_dir}"/mender-artifact checkout "${MENDER_ARTIFACT_VER}"
    popd

    pushd "${TOOLSET_FULL_PATH}/mender/uboot-mender"
        info "building Das U-Boot (Mender flavour)"

        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make --quiet distclean
        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make rpi_3_32b_defconfig
        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make PYTHON=python2 -j $(number_of_cores)
        ARCH=arm CROSS_COMPILE="${cross_compiler_for_mender}" make envtools -j $(number_of_cores)

        cp "u-boot.bin" "${TOOLSET_FULL_PATH}/mender"
        cp tools/env/fw_printenv "${TOOLSET_FULL_PATH}/mender"

        info "generating image for Das U-Boot (Mender flavour)"
        "${uboot_tools}"/mkimage -A arm -T script -C none -n "Boot script" -d "${PIEMAN_DIR}"/files/mender/boot.cmd "${TOOLSET_FULL_PATH}"/mender/boot.scr
    popd

    pushd "${mendersoftware_dir}"/mender
        info "building Mender client"

        env CGO_ENABLED=1 \
            CC="${cross_compiler_for_mender}"gcc \
            GOARCH=arm \
            GOOS=linux \
            GOPATH="${TOOLSET_FULL_PATH}"/mender/client make build

        cp mender "${TOOLSET_FULL_PATH}"/mender
    popd

    pushd "${mendersoftware_dir}"/mender-artifact
        info "building Mender Artifacts Library"

        env GOPATH="${TOOLSET_FULL_PATH}"/mender/client make build

        cp mender-artifact "${TOOLSET_FULL_PATH}"/mender
    popd

    pushd "${TOOLSET_FULL_PATH}/mender"
        finalise_installation "${toolchain_for_mender_dir}" client uboot-mender
    popd
fi

if $(init_installation_if_needed "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"); then
    pushd "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"
        info "fetching 32-bit cross-toolchain for building Das U-Boot"
        wget "https://releases.linaro.org/components/toolchain/binaries/7.4-2019.02/arm-linux-gnueabihf/${dir_with_32bit_toolchain}.tar.xz" -O "${dir_with_32bit_toolchain}.tar.xz"

        info "unpacking archive with 32-bit toolchain for building Das U-Boot"
        tar xJf "${dir_with_32bit_toolchain}.tar.xz"
        rm "${dir_with_32bit_toolchain}.tar.xz"

        info "fetching 64-bit cross-toolchain for building Das U-Boot"
        wget "https://releases.linaro.org/components/toolchain/binaries/7.4-2019.02/aarch64-linux-gnu/${dir_with_64bit_toolchain}.tar.xz" -O "${dir_with_64bit_toolchain}.tar.xz"

        info "unpacking archive with 64-bit toolchain for building Das U-Boot"
        tar xJf "${dir_with_64bit_toolchain}.tar.xz"
        rm "${dir_with_64bit_toolchain}.tar.xz"

        info "fetching Das U-Boot ${UBOOT_VER} from ${UBOOT_URL}"
        git clone --depth=1 -b "v${UBOOT_VER}" https://github.com/u-boot/u-boot.git "u-boot-${UBOOT_VER}"
    popd

    pushd "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}/u-boot-${UBOOT_VER}"
        info "building Das U-Boot"

        ARCH=arm CROSS_COMPILE="${cross_compiler_32bit}" make orangepi_pc_plus_defconfig

        # The host system may have both Python 2 and 3 installed. U-Boot
        # depends on Python 2, so it's necessary to specify it explicitly via
        # the PYTHON variable.
        ARCH=arm CROSS_COMPILE="${cross_compiler_32bit}" PYTHON=python2 make -j $(number_of_cores)

        cp u-boot-sunxi-with-spl.bin "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"/u-boot-sunxi-with-spl-for-opi-pc-plus.bin

        make distclean
        ARCH=arm CROSS_COMPILE="${cross_compiler_32bit}" make orangepi_zero_defconfig
        ARCH=arm CROSS_COMPILE="${cross_compiler_32bit}" PYTHON=python2 make -j $(number_of_cores)

        cp u-boot-sunxi-with-spl.bin "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"/u-boot-sunxi-with-spl-for-opi-zero.bin

        make distclean
        ARCH=aarch64 CROSS_COMPILE="${cross_compiler_64bit}" make nanopi_neo_plus2_defconfig
        ARCH=aarch64 CROSS_COMPILE="${cross_compiler_64bit}" PYTHON=python2 make -j $(number_of_cores)

        cp u-boot-sunxi-with-spl.bin "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"/u-boot-sunxi-with-spl-for-npi-neo-plus2.bin

        cp "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}/u-boot-${UBOOT_VER}"/arch/arm/dts/sun50i-h5-nanopi-neo-plus2.dtb "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"/sun50i-h5-nanopi-neo-plus2.dtb

        cp tools/mkimage "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"
    popd

    pushd "${TOOLSET_FULL_PATH}/uboot-${UBOOT_VER}"
        finalise_installation "${dir_with_32bit_toolchain}" \
                              "${dir_with_64bit_toolchain}" \
                              "u-boot-${UBOOT_VER}" \
                              uboot-env
    popd
fi

# Correct ownership if needed
pieman_dir_ownership="$(get_ownership "${PIEMAN_DIR}")"
if [ "$(get_ownership "${TOOLSET_FULL_PATH}")" != "${pieman_dir_ownership}" ]; then
    info "correcting ownership for ${TOOLSET_FULL_PATH}"
    chown -R "${pieman_dir_ownership}" "${TOOLSET_FULL_PATH}"
fi

if ${PREPARE_ONLY_TOOLSET}; then
    success "exiting since PREPARE_ONLY_TOOLSET is set to true"

    exit 0
fi
