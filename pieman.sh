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

if [ "`id -u`" -ne "0" ]; then
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

BASE_DIR=${BASE_DIR:=""}

BUILD_DIR=${BUILD_DIR:="build"}

DEVICE=${DEVICE:="rpi-3-b"}

ENABLE_NONFREE=${ENABLE_NONFREE:=false}

ENABLE_UNIVERSE=${ENABLE_UNIVERSE:=false}

INCLUDES=${INCLUDES:=""}

OS=${OS:="raspbian-stretch-armhf"}

PASSWORD=${PASSWORD:="secret"}

PROJECT_NAME=${PROJECT_NAME:=`uuidgen`}

PIEMAN_BIN=${PIEMAN_BIN:='bin'}

PYTHON=${PYTHON:=`which python3`}

set +x

#
# Internal params
#

R=${BUILD_DIR}/${PROJECT_NAME}/chroot

BOOT=${BUILD_DIR}/${PROJECT_NAME}/boot

MOUNT_POINT=${BUILD_DIR}/${PROJECT_NAME}/mount_point

ETC=${R}/etc

USR_BIN=${R}/usr/bin

IMAGE=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.img

KEYRING=/tmp/atomatically-generated-keyring.gpg

SAVE=false

SOURCE_DIR=devices/${DEVICE}/${OS}

YML_FILE=${SOURCE_DIR}/pieman.yml

# OS must stick to the following naming convention:
# <distro name>-<codename>-<arch>.
IFS='-' read -ra PIECES <<< ${OS}

. ./functions.sh

if [ $# -gt 0 ]; then
    command=${1}
    if [[ ${command} -eq "save" ]]; then
        if [ -t 1 ]; then
            fatal "Cannot save to a terminal. Use redirect."
            exit 1
        else
            SAVE=true
        fi
    else
        fatal "Unknown command ${command}."
        exit 1
    fi
fi

check_dependencies

check_required_directories

check_required_files

choose_debootstrap

choose_user_mode_emulation_binary

set_traps

create_keyring

create_necessary_dirs

# Set to true the parameters recommended by the maintainer of the image.
params="`get_attr_or_nothing ${OS} params`"
for param in ${params}; do
    eval $param=true
done

run_scripts "bootstrap"

umount_required_filesystems

info "creating image"
dd if=/dev/zero of=${IMAGE} bs=1024 seek=$[ 1024 * 1024 * 7 ] count=1

parted ${IMAGE} mktable msdos

parted ${IMAGE} mkpart p fat32 4MiB 54MiB

parted -s ${IMAGE} -- mkpart primary ext2 58MiB -1s

# parts[0] and parts[1] will store devices names for boot and rootfs
# partitions, respectively.
parts=()
kpartx_output="`kpartx -a -p ${PROJECT_NAME}p -v ${IMAGE}`"
while read p; do
    parts+=(`echo ${p} | awk '{print $3}'`)
done <<< "${kpartx_output}"

# It may take a while until devices appear in /dev/mapper.
max_retries=30
for i in `eval echo {1..${max_retries}}`; do
    if [ -z `ls /dev/mapper/${parts[0]} 2> /dev/null` ]; then
        sleep 1
    else
        break
    fi
done

if [ -z `ls /dev/mapper/${parts[0]} 2> /dev/null` ]; then
    fatal "/dev/mapper/${parts[0]} does not exist"
    exit 1
fi

info "formatting boot partition"
mkfs.vfat /dev/mapper/${parts[0]} 1>&2-

info "formatting rootfs partition"
mkfs.ext4 /dev/mapper/${parts[1]} 1>&2-

mount /dev/mapper/${parts[0]} ${MOUNT_POINT}

rsync -a ${BOOT}/ ${MOUNT_POINT}

umount ${MOUNT_POINT}

mount /dev/mapper/${parts[1]} ${MOUNT_POINT}

rsync -a ${R}/ ${MOUNT_POINT}

info "cleaning up"
cleanup

if ${SAVE}; then
    gzip ${IMAGE}
    dd if=${IMAGE}.gz bs=4M
fi
