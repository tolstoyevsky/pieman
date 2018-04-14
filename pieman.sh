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

if [ ! -r ./functions.sh ] ; then
    >&2 echo "'./functions.sh' required script not found!"
    exit 1
fi

set -e

set -x

#
# User defined params
#

ALLOW_UNAUTHENTICATED=${ALLOW_UNAUTHENTICATED:=false}

BASE_DIR=${BASE_DIR:=""}

BUILD_DIR=${BUILD_DIR:="build"}

CREATE_ONLY_CHROOT=${CREATE_ONLY_CHROOT:=false}

DEVICE=${DEVICE:="rpi-3-b"}

ENABLE_CUSTOM_DNS=${ENABLE_CUSTOM_DNS:=""}

ENABLE_BZIP2=${ENABLE_BZIP2:=false}

ENABLE_BASIC_YANDEX_DNS=${ENABLE_BASIC_YANDEX_DNS:=false}

ENABLE_FAMILY_YANDEX_DNS=${ENABLE_FAMILY_YANDEX_DNS:=false}

ENABLE_GOOGLE_DNS=${ENABLE_GOOGLE_DNS:=false}

ENABLE_GZIP=${ENABLE_GZIP:=true}

ENABLE_SUDO=${ENABLE_SUDO:=true}

ENABLE_NONFREE=${ENABLE_NONFREE:=false}

ENABLE_UNATTENDED_INSTALLATION=${ENABLE_UNATTENDED_INSTALLATION:=false}

ENABLE_UNIVERSE=${ENABLE_UNIVERSE:=false}

ENABLE_USER=${ENABLE_USER:=true}

ENABLE_XZ=${ENABLE_XZ:=false}

HOST_NAME=${HOST_NAME:="pieman-${DEVICE}"}

INCLUDES=${INCLUDES:=""}

OS=${OS:="raspbian-stretch-armhf"}

# Do not show the root password.
set +x
PASSWORD=${PASSWORD:="secret"}
# The line 'set +x' pollutes the output, so it's better to remove it.
tput cuu 1
# Emulate the 'set -x' output.
>&2 echo "+ PASSWORD=*****"
set -x

PROJECT_NAME=${PROJECT_NAME:=$(uuidgen)}

PIEMAN_BIN=${PIEMAN_BIN:='bin'}

PYTHON=${PYTHON:=$(which python3)}

SUDO_REQUIRE_PASSWORD=${SUDO_REQUIRE_PASSWORD:=true}

TIME_ZONE=${TIME_ZONE:="Etc/UTC"}

USER_NAME=${USER_NAME:="cusdeb"}

# Do not show the user password.
set +x
USER_PASSWORD=${USER_PASSWORD:="secret"}
tput cuu 1
>&2 echo "+ USER_PASSWORD=*****"
set -x

set +x

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

# shellcheck disable=SC2034
BASE_PACKAGES=""

IMAGE=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.img

# shellcheck disable=SC2034
KEYRING=/tmp/atomatically-generated-keyring.gpg

# shellcheck disable=SC2034
PM_OPTIONS=""

SOURCE_DIR=devices/${DEVICE}/${OS}

# shellcheck disable=SC2034
YML_FILE=${SOURCE_DIR}/pieman.yml

# OS must stick to the following naming convention:
# <distro name>-<codename>-<arch>.
# shellcheck disable=SC2034
IFS='-' read -ra PIECES <<< ${OS}

. ./functions.sh

check_mutually_exclusive_params \
    ENABLE_GOOGLE_DNS \
    ENABLE_BASIC_YANDEX_DNS \
    ENABLE_FAMILY_YANDEX_DNS \
    ENABLE_CUSTOM_DNS

check_mutually_exclusive_params \
    ENABLE_BZIP2 \
    ENABLE_GZIP \
    ENABLE_XZ

check_dependencies

check_required_directories

check_required_files

choose_debootstrap

choose_user_mode_emulation_binary

set_traps

create_necessary_dirs

# Set to true the parameters recommended by the maintainer of the image.
params="$(get_attr_or_nothing ${OS} params)"
for param in ${params}; do
    # shellcheck disable=SC2086
    eval ${param}=true
done

# Expand the base system.
base_packages="$(get_attr_or_nothing ${OS} base)"
if [ ! -z "${base_packages}" ]; then
    for package in ${base_packages}; do
        add_package_to_base_packages "${package}"
    done
fi

run_scripts "bootstrap"

umount_required_filesystems

info "creating image"
create_image "$(calc_size "${R}")"

LOOP_DEV=$(losetup --partscan --show --find "${IMAGE}")
boot_partition="${LOOP_DEV}p1"
root_partition="${LOOP_DEV}p2"

# It may take a while until devices appear in /dev.
max_retries=30
for i in $(eval echo "{1..${max_retries}}"); do
    if [ -z "$(ls "${boot_partition}" 2> /dev/null)" ]; then
        info "there is no ${boot_partition} so far ($((max_retries - i)) attempts left)"
        sleep 1
    else
        break
    fi
done

if [ -z "$(ls "${boot_partition}" 2> /dev/null)" ]; then
    fatal "${boot_partition} does not exist"
    exit 1
fi

info "formatting boot partition"
mkfs.vfat "${boot_partition}" 1>&2-

info "formatting rootfs partition"
mkfs.ext4 "${root_partition}" 1>&2-

# The root partition is expanded to fit the SD card. However, the size of the
# SD card is currently unknown, so reserving 5% of the filesystem blocks at
# this stage is incorrect.
tune2fs -m 0 "${root_partition}"

mount "${boot_partition}" "${MOUNT_POINT}"

rsync -a "${BOOT}"/ "${MOUNT_POINT}"

umount "${MOUNT_POINT}"

mount "${root_partition}" "${MOUNT_POINT}"

rsync -apS "${R}"/ "${MOUNT_POINT}"

cleanup

compressor="$(choose_compressor)"

if [ ! -z "${compressor}" ]; then
    executable="$(echo "${compressor}" | cut -d' ' -f1)"
    extension="$(echo "${compressor}" | cut -d' ' -f2)"

    info "compressing image using ${executable}"
    ${executable} "${IMAGE}"
fi

success "${IMAGE}${extension} was built. Use Etcher (https://etcher.io) to burn it to your SD card."
