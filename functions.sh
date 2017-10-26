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

check_if_variable_is_set() {
    var_name=$1
    if [ -z "${!var_name}" ]; then
        >&2 echo "${var_name} is not specified"
        exit 1
    fi
}

# It's quite dangerous to run some of the functions from the script if the
# following variables are undefined, so it's necessary to check the variables
# before running the script.
for var in BUILD_DIR IMAGE KEYRING MOUNT_POINT PIECES PROJECT_NAME PYTHON R SOURCE_DIR USR_BIN YML_FILE; do
    check_if_variable_is_set ${var}
done

#
# APT-related functions
#

clean() {
    chroot_exec apt-get clean
    rm -rf ${R}/var/lib/apt/lists/*
}

update_indexes() {
    chroot_exec apt-get update
}

upgrade() {
    # TODO: find a way to get rid of --allow-unauthenticated
    chroot_exec apt-get -y --allow-unauthenticated dist-upgrade
}

install_packages() {
    # TODO: find a way to get rid of --allow-unauthenticated
    chroot_exec apt-get -y --allow-unauthenticated install $*
}

purge_packages() {
    chroot_exec apt-get -y purge $*
}

#
# Base functions
#

check_dependencies() {
    if [ ! -e /usr/bin/qemu-arm-static ]; then
        fatal "there is no /usr/bin/qemu-arm-static. Run apt-get install qemu-user-static on Debian/Ubuntu to fix it."
        exit 1
    fi

    if [ ! -e /usr/bin/qemu-aarch64-static ]; then
        fatal "there is no /usr/bin/qemu-aarch64-static. Run apt-get install qemu-user-static on Debian/Ubuntu to fix it."
        exit 1
    fi

    for dep in debootstrap gpg kpartx parted python3 rsync wget; do
        if [ -z `which ${dep}` ]; then
            fatal "there is no ${dep}. Run apt-get install ${dep} on Debian/Ubuntu to fix it."
            exit 1
        fi
    done

    if [ -z `which mkpasswd` ]; then
        fatal "there is no mkpasswd. Run apt-get install whois on Debian/Ubuntu to fix it."
        exit 1
    fi

    if [ -z `which uuidgen` ]; then
        fatal "there is no uuidgen. Run apt-get install uuid-runtime on Debian/Ubuntu to fix it."
        exit 1
    fi
}

choose_user_mode_emulation_binary() {
    if [ ! ${#PIECES[@]} -eq 3 ]; then
        fatal "Use the following naming convention for OS: <distro name>-<codename>-<arch>."
        exit 1
    fi

    case ${PIECES[2]} in
    armhf)
        EMULATOR=/usr/bin/qemu-arm-static
        ;;
    arm64)
        EMULATOR=/usr/bin/qemu-aarch64-static
        ;;
    *)
        fatal "Unknown architecture ${PIECES[2]}."
        exit 1
    esac
}

cleanup() {
    set -x

    rm -f ${KEYRING}

    umount ${MOUNT_POINT} 2> /dev/null || /bin/true

    umount_required_filesystems

    if [ -f ${IMAGE} ]; then
        kpartx -d -p ${PROJECT_NAME}p -v ${IMAGE}
    fi

    set +x
}

run_scripts() {
    dir=${1}
    if [ -d ${dir} ]; then
        for script in ${dir}/*.sh; do
            info "running ${script} from ${dir}"
            . ${script}
        done
    else
        info "cannot run anything from ${dir} since it does not exist."
    fi
}

set_traps() {
    # Call "cleanup" function on the following signals:
    # EXIT, SIGHUP, SIGINT, SIGQUIT and SIGABRT.
    trap cleanup 0 1 2 3 6
}

#
# Chroot-related functions
#

chroot_exec() {
    chroot ${R} $* 1>&2-
}

chroot_exec_sh() {
    chroot ${R} sh -c "${*}" 1>&2-
}

#
# Debootstrap-related functions
#

run_first_stage() {
    arch=${PIECES[2]}
    codename=${PIECES[1]}
    primary_repo=`get_attr ${OS} repos | head -n1`
    debootstrap --arch=${arch} --foreign --variant=minbase --keyring=${KEYRING} ${codename} ${R} ${primary_repo} 1>&2-

    install_user_mode_emulation_binary
}

run_second_stage() {
    chroot_exec debootstrap/debootstrap --second-stage
}

#
# Print messages in different colors
#

text_in_red_color=$(tput setaf 1)

text_in_green_color=$(tput setaf 2)

text_in_yellow_color=$(tput setaf 3)

reset=$(tput sgr0)

fatal() {
    >&2 echo "${text_in_red_color}Fatal${reset}: ${1}"
}

info() {
    >&2 echo "${text_in_yellow_color}Info${reset}: ${1}"
}

success() {
    >&2 echo "${text_in_green_color}Success${reset}: ${1}"
}

#
# FS-related functions
#

check_required_directories() {
    dirs="bootstrap devices"

    for dir in ${dirs}; do
        if [ ! -d ${dir} ] ; then
            fatal "${dir} required directory not found!"
            exit 1
        fi
    done
}

check_required_files() {
    if [ ! -f ${YML_FILE} ]; then
        fatal "${YML_FILE} does not exist"
        exit 1
    fi
}

create_dir() {
    dir=$1

    if [ ! -d ${dir} ]; then
        mkdir -p ${dir}
    fi
}

create_necessary_dirs() {
    target=${BUILD_DIR}/${PROJECT_NAME}
    if [ -d ${target} ]; then
        fatal "${target} already exists"
        exit 1
    fi

    create_dir ${target}
    create_dir ${target}/boot
    create_dir ${target}/mount_point
}

install_exec() {
    install -o root -g root -m 744 $*
}

install_readonly() {
    install -o root -g root -m 644 $*
}

install_user_mode_emulation_binary() {
    # It's not possible to use install_exec for installing user mode emulation
    # binaries. For details, see https://github.com/drtyhlpr/rpi23-gen-image/pull/85.
    install -m 755 -o root -g root ${EMULATOR} ${USR_BIN}
}

mount_required_filesystems() {
    mount -t proc none "${R}/proc"
    mount -t sysfs none "${R}/sys"

    # To prevent the following error message:
    # E: Can not write log (Is /dev/pts mounted?) - posix_openpt (19: No such device)
    if [ -d "${R}/dev/pts" ] ; then
        mount --bind /dev/pts "${R}/dev/pts"
    fi
}

umount_required_filesystems() {
    umount -l "${R}/proc"    2> /dev/null || /bin/true
    umount -l "${R}/sys"     2> /dev/null || /bin/true
    umount    "${R}/dev/pts" 2> /dev/null || /bin/true
}

#
# Image attributes-related functions
#

get_attr() {
    output="`${PYTHON} utils/image_attrs.py --file=${YML_FILE} $* 2>&1`"
    if [ $? -ne 0 ]; then
        fatal "while getting the specified attribute from ${YML_FILE} occurred the following error: ${output}."
        exit 1
    fi

    echo "${output}"
}

get_attr_or_nothing() {
    ${PYTHON} utils/image_attrs.py --file=${YML_FILE} $* 2> /dev/null || /bin/true
}

#
# Unsorted functions
#

add_package_to_includes() {
    package=${1}
    if [ -z `echo ${INCLUDES} | grep ",${package}"` ]; then
        INCLUDES="${INCLUDES},${package}"
    fi
}

create_keyring() {
    for key in keys/${PIECES[0]}/*; do
        gpg --no-default-keyring --keyring=${KEYRING} --import ${key}
    done
}
