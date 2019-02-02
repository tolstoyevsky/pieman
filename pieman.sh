#!/bin/bash
# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
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

if [ "$(id -u)" -ne "0" ]; then
    >&2 echo "This script must be run as root"
    exit 1
fi

if [ ! -r ./essentials.sh ] ; then
    >&2 echo "'./essentials.sh' required script not found!"
    exit 1
fi

. ./essentials.sh

set -eE

#
# User defined params
#

def_bool_var ALLOW_UNAUTHENTICATED false

def_var BASE_DIR ""

def_var BUILD_DIR "build"

def_bool_var COMPRESS_WITH_BZIP2 false

def_bool_var COMPRESS_WITH_GZIP false

def_bool_var COMPRESS_WITH_XZ false

def_bool_var CREATE_ONLY_MENDER_ARTIFACT false

def_bool_var CREATE_ONLY_CHROOT false

def_var DEVICE "rpi-3-b"

def_var ENABLE_CUSTOM_DNS ""

def_bool_var ENABLE_BASIC_YANDEX_DNS false

def_bool_var ENABLE_BSC_CHANNEL false

def_bool_var ENABLE_FAMILY_YANDEX_DNS false

def_bool_var ENABLE_GOOGLE_DNS false

def_bool_var ENABLE_SUDO true

def_bool_var ENABLE_MENDER false

def_bool_var ENABLE_NONFREE false

def_bool_var ENABLE_UNATTENDED_INSTALLATION false

def_bool_var ENABLE_UNIVERSE false

def_bool_var ENABLE_USER true

def_var HOST_NAME "pieman-${DEVICE}"

def_var IMAGE_OWNERSHIP "$(get_ownership "$0")"

def_int_var IMAGE_ROOTFS_SIZE 0

def_var INCLUDES ""

def_var LOCALE "en_US.UTF-8"

def_var MENDER_ARTIFACT_NAME "release-1_1.7.0"

def_int_var MENDER_DATA_SIZE 128

def_int_var MENDER_INVENTORY_POLL_INTERVAL 86400

def_int_var MENDER_RETRY_POLL_INTERVAL 300

def_var MENDER_SERVER_URL "https://hosted.mender.io"

def_var MENDER_TENANT_TOKEN ""

def_int_var MENDER_UPDATE_POLL_INTERVAL 1800

def_var OS "raspbian-stretch-armhf"

def_protected_var PASSWORD "secret"

def_var PIEMAN_DIR "$(pwd)"

def_var PIEMAN_UTILS_DIR "${PIEMAN_DIR}/pieman/bin"

def_bool_var PREPARE_ONLY_TOOLSET false

def_var PROJECT_NAME "$(uuidgen)"

def_var PYTHON "$(which python3)"

def_var REDIS_HOST "127.0.0.1"

def_int_var REDIS_PORT 6379

def_bool_var SUDO_REQUIRE_PASSWORD true

def_var TIME_ZONE "Etc/UTC"

def_var TOOLSET_DIR "${PIEMAN_DIR}/toolset"

def_var USER_NAME "cusdeb"

def_protected_var USER_PASSWORD "secret"

#
# Internal params
#

R=${BUILD_DIR}/${PROJECT_NAME}/chroot

BOOT=${BUILD_DIR}/${PROJECT_NAME}/boot

MOUNT_POINT=${BUILD_DIR}/${PROJECT_NAME}/mount_point

# shellcheck disable=SC2034
ETC=${R}/etc

# shellcheck disable=SC2034
USR_BIN=${R}/usr/bin

ARTIFACT="${PIEMAN_DIR}/${BUILD_DIR}/${PROJECT_NAME}.mender"

# shellcheck disable=SC2034
BASE_PACKAGES=""

BUILD_TYPE="${IMAGE_FOR_RPI}"

# shellcheck disable=SC2034
FIRSTBOOT="/tmp/firstboot-${PROJECT_NAME}.sh"

IMAGE=${BUILD_DIR}/${PROJECT_NAME}.img

# shellcheck disable=SC2034
KEYRING="/tmp/atomatically-generated-keyring-for-${PROJECT_NAME}.gpg"

# shellcheck disable=SC2034
PM_OPTIONS=""

# shellcheck disable=SC2034
EXIT_REQUEST="EXIT"

# shellcheck disable=SC2034
REDIS_IS_AVAILABLE=true

SOURCE_DIR=devices/${DEVICE}/${OS}

# shellcheck disable=SC2034
YML_FILE=${SOURCE_DIR}/pieman.yml

split_os_name_into_pieces

run_scripts "helpers"

check_mutually_exclusive_params \
    BASE_DIR \
    CREATE_ONLY_CHROOT

check_mutually_exclusive_params \
    ENABLE_GOOGLE_DNS \
    ENABLE_BASIC_YANDEX_DNS \
    ENABLE_FAMILY_YANDEX_DNS \
    ENABLE_CUSTOM_DNS

check_mutually_exclusive_params \
    COMPRESS_WITH_BZIP2 \
    COMPRESS_WITH_GZIP \
    COMPRESS_WITH_XZ

check_mutually_exclusive_params \
    CREATE_ONLY_MENDER_ARTIFACT \
    CREATE_ONLY_CHROOT \
    ENABLE_MENDER

check_dependencies

check_ownership_format

check_redis # relevant only if ENABLE_BSC_CHANNEL is set to true

check_required_directories

check_required_files

info "checking toolset"
. toolset.sh

# shellcheck source=./pieman/pieman/build_status_codes
. "${PIEMAN_DIR}"/pieman/pieman/build_status_codes

if ${ENABLE_MENDER}; then
    if [ ! -d "${TOOLSET_DIR}/mender" ]; then
        fatal "Mender is not installed." \
              "Check Mender dependencies and run Pieman" \
              "with PREPARE_ONLY_TOOLSET=true."
        exit 1
    fi

    if [ "${DEVICE}" != "rpi-3-b" ] || [ "${OS}" != "raspbian-stretch-armhf" ]; then
        fatal "cannot create Mender compatible image for the specified" \
              "device and operating system. OS=raspbian-stretch-armhf and" \
              "DEVICE=rpi-3-b is supported only."
        exit 1
    fi
fi

choose_user_mode_emulation_binary

init_debootstrap

set_traps

create_temporary_dirs

start_bscd # relevant only if ENABLE_BSC_CHANNEL is set to true

if ${CREATE_ONLY_MENDER_ARTIFACT}; then
    BUILD_TYPE="${IMAGE_MENDER_ARTIFACT}"
fi

if ${ENABLE_MENDER}; then
    BUILD_TYPE="${IMAGE_FOR_RPI_WITH_MENDER_CLIENT}"
fi

# Set to true the parameters recommended by the maintainer of the image.
params="$(get_attr_or_nothing "${OS}" params)"
for param in ${params}; do
    # shellcheck disable=SC2086
    eval ${param}=true
done

run_scripts "bootstrap"

umount_required_filesystems

info "creating image"

if [ "${IMAGE_ROOTFS_SIZE}" -gt 0 ]; then
    # check if IMAGE_ROOTFS_SIZE can fit rootfs
    chroot_size="$(calc_size -m "${R}")"
    chroot_and_metadata_size="$(python3 -c "import math; print(math.ceil(${chroot_size} / 10))")"
    if [ "${chroot_and_metadata_size}" -gt "${IMAGE_ROOTFS_SIZE}" ]; then
        fail "IMAGE_ROOTFS_SIZE is too small. Try at least ${chroot_and_metadata_size}."
    fi
    root_partition_size="${IMAGE_ROOTFS_SIZE}"
    metadata_size="0"
else
    root_partition_size="$(calc_size -m "${R}")"
    metadata_size="$(python3 -c "import math; print(math.ceil(${root_partition_size} / 10))")"
fi
total=$((root_partition_size + metadata_size))

case "${BUILD_TYPE}" in
"${IMAGE_FOR_RPI}")
    image_size="$(create_image 4 fat32:100 "${total}")"
    info "${IMAGE} of size ${image_size}M was successfully created"

    send_request_to_bsc_server CREATED_IMAGE_CODE

    info "creating loop device and scanning partition table"

    scan_partition_table

    info "${LOOP_DEV} is successfully created"

    info "formatting partitions"

    format_partitions vfat ext4

    send_request_to_bsc_server FORMATTED_PARTITION_CODE

    mount "${LOOP_DEV}p1" "${MOUNT_POINT}"

    rsync -a "${BOOT}"/ "${MOUNT_POINT}"

    umount "${MOUNT_POINT}"

    mount "${LOOP_DEV}p2" "${MOUNT_POINT}"

    rsync -apS "${R}"/ "${MOUNT_POINT}"

    send_request_to_bsc_server SYNCED_CODE

    ;;
"${IMAGE_FOR_RPI_WITH_MENDER_CLIENT}")
    image_size="$(create_image 16 fat32:100 "${total}" "${total}" "${MENDER_DATA_SIZE}")"
    info "${IMAGE} of size ${image_size}M was successfully created"

    send_request_to_bsc_server CREATED_IMAGE_CODE

    info "creating loop device and scanning partition table"

    scan_partition_table

    info "${LOOP_DEV} is successfully created"

    info "formatting partitions"

    format_partitions vfat ext4 ext4 ext4

    send_request_to_bsc_server FORMATTED_PARTITION_CODE

    mount "${LOOP_DEV}p1" "${MOUNT_POINT}"

    rsync -a "${BOOT}"/ "${MOUNT_POINT}"

    cp "${TOOLSET_DIR}"/mender/boot.scr "${MOUNT_POINT}"
    cp "${TOOLSET_DIR}"/mender/u-boot.bin "${MOUNT_POINT}"/kernel7.img
    sed -i -e "s/\b[ ]root=[^ ]*/ root=\${mender_kernel_root}/" "${MOUNT_POINT}"/cmdline.txt

    umount "${MOUNT_POINT}"

    mount "${LOOP_DEV}p2" "${MOUNT_POINT}"

    rsync -apS "${R}"/ "${MOUNT_POINT}"

    send_request_to_bsc_server SYNCED_CODE

    install_mender

    umount "${MOUNT_POINT}"

    # The data partition has to contain /mender/device_type and
    # /u-boot/fw_env.config
    mount "${LOOP_DEV}p4" "${MOUNT_POINT}"
    mkdir "${MOUNT_POINT}"/mender
    mkdir "${MOUNT_POINT}"/u-boot
    install -m 0444 "${PIEMAN_DIR}"/files/mender/device_type "${MOUNT_POINT}"/mender
    install -m 0644 "${PIEMAN_DIR}"/files/mender/fw_env.config "${MOUNT_POINT}"/u-boot

    ;;
"${IMAGE_MENDER_ARTIFACT}")
    dd if=/dev/zero of="${IMAGE}" bs="$((1024 * 1024))" seek="${total}" count=1

    send_request_to_bsc_server CREATED_IMAGE_CODE

    LOOP_DEV="$(losetup -f)"

    losetup "${LOOP_DEV}" "${IMAGE}"

    mkfs.ext4 "${LOOP_DEV}"

    send_request_to_bsc_server FORMATTED_PARTITION_CODE

    mount "${LOOP_DEV}" "${MOUNT_POINT}"

    rsync -apS "${R}"/ "${MOUNT_POINT}"

    send_request_to_bsc_server SYNCED_CODE

    install_mender

    umount "${MOUNT_POINT}"

    info "converting ${IMAGE} into artifact"

    "${TOOLSET_DIR}"/mender/mender-artifact write rootfs-image \
        --update "${IMAGE}" \
        --output-path "${ARTIFACT}" \
        --artifact-name "${MENDER_ARTIFACT_NAME}" \
        --device-type raspberrypi3

    rm "${IMAGE}"

    IMAGE="${ARTIFACT}"

    ;;
*)
    fatal "unknown build type"
    exit 1

    ;;
esac

cleanup

compressor="$(choose_compressor)"

if [ ! -z "${compressor}" ]; then
    executable="$(echo "${compressor}" | cut -d' ' -f1)"
    extension="$(echo "${compressor}" | cut -d' ' -f2)"

    info "compressing image using ${executable}"
    ${executable} "${IMAGE}"
fi

chown "${IMAGE_OWNERSHIP}" "${IMAGE}${extension}"

if check_if_run_in_docker; then
    image="$(basename "${IMAGE}${extension}")"
else
    image="${IMAGE}${extension}"
fi

if ${CREATE_ONLY_MENDER_ARTIFACT}; then
    success "${image} was built. Upload it to hosted.mender.io to provide for OTA updates."
else
    success "${image} was built. Use Etcher (https://etcher.io) to burn it to your SD card."
fi

send_request_to_bsc_server SUCCESSFUL_CODE

stop_bscd
