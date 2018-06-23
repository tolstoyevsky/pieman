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

# Adds the specified item to a list. The variable name, which represents the
# list, and delimiter must be passed as the second and third parameters to the
# function respectively.
# Globals:
#     None
# Arguments:
#     Item
#     Environment variable name
#     Delimiter
# Returns:
#     None
add_item_to_list() {
    local item="${1}"
    local var_name=${2}
    local delimiter="${3}"
    # shellcheck disable=SC2086
    if ! echo ${!var_name} | grep -q "${delimiter}${item}"; then
        if [ "${delimiter}" == " " ]; then
            eval ${var_name}="\"${!var_name}${delimiter}${item}\""
        else
            eval ${var_name}="${!var_name}${delimiter}${item}"
        fi
    fi
}

# Checks if all required dependencies are installed on the system.
# Globals:
#     COMPRESS_WITH_BZIP2
#     COMPRESS_WITH_GZIP
#     COMPRESS_WITH_XZ
# Arguments:
#     None
# Returns:
#     None
check_dependencies() {
    if [ -z "$(which dpkg)" ]; then
        # Do not mention Debian or Ubuntu since dpkg is a part of
        # the base system there.
        fatal "there is no dpkg. Run dnf install dpkg on Fedora to fix it."
        exit 1
    fi

    if [ ! -e /usr/bin/qemu-arm-static ]; then
        fatal "there is no /usr/bin/qemu-arm-static." \
              "Run apt-get install qemu-user-static on Debian/Ubuntu or" \
              "dnf install qemu-user-static on Fedora."
        exit 1
    fi

    if [ ! -e /usr/bin/qemu-aarch64-static ]; then
        fatal "there is no /usr/bin/qemu-aarch64-static."
              "Run apt-get install qemu-user-static on Debian/Ubuntu or" \
              "dnf install qemu-user-static on Fedora."
        exit 1
    fi

    if [ -z "$(which mkpasswd)" ]; then
        fatal "there is no mkpasswd." \
              "Run apt-get install whois on Debian/Ubuntu or" \
              "dnf install expect on Fedora."
        exit 1
    fi

    if [ -z "$(which uuidgen)" ]; then
        # Do not mention Fedora since uuidgen belongs to the util-linux package
        # which is a key component of the system.
        fatal "there is no uuidgen." \
              "Run apt-get install uuid-runtime on Debian/Ubuntu to fix it."
        exit 1
    fi

    if ! check_pieman_version; then
        fatal "Pieman package ${PIEMAN_MAJOR_VER}.${PIEMAN_MINOR_VER} or " \
              "higher is required." \
              "Execute 'sudo pip3 install pieman --upgrade' " \
              "to upgrade the package."
        exit 1
    fi

    if ! check_python_version; then
        fatal "Python ${PYTHON_MAJOR_VER}.${PYTHON_MINOR_VER} or "\
              "higher is required." \
              "$(${PYTHON} -V) is used instead."
        exit 1
    fi

    if ! ${PYTHON} -c "import yaml"; then
        fatal "there is no yaml python package." \
              "Run apt-get install python3-yaml on Debian/Ubuntu or" \
              "dnf install python3-PyYAML on Fedora"
        exit 1
    fi

    if ${COMPRESS_WITH_BZIP2}; then
        if [ -z "$(which bzip2)" ]; then
            fatal "there is no bzip2." \
                  "Run apt-get install bzip2 on Debian/Ubuntu or" \
                  "dnf install bzip2 on Fedora."
            exit 1
        fi
    fi

    if ${COMPRESS_WITH_XZ}; then
        if [ -z "$(which xz)" ]; then
            fatal "there is no xz." \
                  "Run apt-get install xz-utils on Debian/Ubuntu or" \
                  "dnf install xz on Fedora."
            exit 1
        fi
    fi
}

# Checks if two or more mutually exclusive parameters are set true or does not
# contain an empty string.
# The function has the following side effect: it assigns an empty string to the
# parameters which are set to false.
# Globals:
#     None
# Arguments:
#     Parameters
# Returns:
#     None
check_mutually_exclusive_params() {
    for param in "$@"; do
        # false is considered as non-empty string, so use empty string
        # explicitly.
        if [[ ${!param} == false ]]; then
            # shellcheck disable=SC2086
            declare $param=""
        fi
    done

    for a in "$@"; do
        for b in "$@"; do
            if [[ "${a}" == "${b}" ]]; then
                continue
            fi

            if [ ! -z "${!a}" ] && [ ! -z "${!b}" ]; then
                fatal "${a} and ${b} conflict with each other."
                exit 1
            fi
        done
    done
}

# Checks if the IMAGE_OWNERSHIP value follows the format.
# Globals:
#     IMAGE_OWNERSHIP
# Arguments:
#     None
# Returns:
#     None
check_ownership_format() {
    local ownership=()
    local re="^[0-9]+$"

    IFS=':' read -ra ownership <<< "${IMAGE_OWNERSHIP}"
    if [ "${#ownership[@]}" -ne "2" ] || ! [[ "${ownership[0]}" =~ ${re} ]] || ! [[ "${ownership[1]}" =~ ${re} ]]; then
        fatal "IMAGE_OWNERSHIP must follow the format: \"uid:gid\"."
        exit 1
    fi
}

# Checks if the Pieman package version is equal or greater than required.
# Globals:
#     PIEMAN_MAJOR_VER
#     PIEMAN_MINOR_VER
# Arguments:
#     None
# Returns:
#     Boolean
check_pieman_version() {
    local pieman_version=(0 0)
    local output=""

    output="$(${PYTHON} -c "import pieman; print(pieman.__version__)" 2>&1)"
    # Pieman package 0.1 doesn't have the __version__ module attribute, so we
    # have to provide for backwards compatibility.
    # TODO: check exit code directly with e.g. 'if mycmd;'
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        IFS='.' read -ra pieman_version <<< "${output}"
    fi

    if (("${pieman_version[0]}" >= "${PIEMAN_MAJOR_VER}")) && (("${pieman_version[1]}" >= "${PIEMAN_MINOR_VER}")); then
        true
    else
        false
    fi
}

# Checks if the current Python version is equal or greater than required.
# Globals:
#     PYTHON_MAJOR_VER
#     PYTHON_MINOR_VER
# Arguments:
#     None
# Returns:
#     Boolean
check_python_version() {
    local current_python_version=()

    IFS='.' read -ra current_python_version <<< "$(${PYTHON} -V | cut -d' ' -f2)"

    if (("${current_python_version[0]}" >= "${PYTHON_MAJOR_VER}")) && (("${current_python_version[1]}" >= "${PYTHON_MINOR_VER}")); then
        true
    else
        false
    fi
}

# Chooses a suitable compressor depending on which parameters passed (or didn't
# pass) the user.
# Globals:
#     COMPRESS_WITH_BZIP2
#     COMPRESS_WITH_GZIP
#     COMPRESS_WITH_XZ
# Arguments:
#     None
# Returns:
#     String which consists of the executable name and the extension name
choose_compressor() {
    if ${COMPRESS_WITH_BZIP2}; then
        echo "bzip2 .bz2"
    fi

    if ${COMPRESS_WITH_GZIP}; then
        echo "gzip .gz"
    fi

    if ${COMPRESS_WITH_XZ}; then
        echo "xz .xz"
    fi
}

# Looks for debootstrap installed locally. If it does not exist, tries to find
# debootstrap installed globally. When the function succeeds, it assigns the
# corresponding executable name to DEBOOTSTRAP_EXEC and the full path of the
# executable to DEBOOTSTRAP_DIR (only in case of a local debootstrap).
# Otherwise, the function exits with the exit code 1.
# Globals:
#     DEBOOTSTRAP_DIR
#     DEBOOTSTRAP_EXEC
# Arguments:
#     None
# Returns:
#     None
choose_debootstrap() {
    local ver=""

    if [ -f debootstrap/debootstrap ]; then
        DEBOOTSTRAP_EXEC="env DEBOOTSTRAP_DIR=$(pwd)/debootstrap ./debootstrap/debootstrap"

        # After cloning the debootstrap git repo the program is a fully
        # functional, but does not have a correct version number. However, the
        # version can be found in the source package changelog.
        ver=$(sed 's/.*(\(.*\)).*/\1/; q' debootstrap/debian/changelog)
    elif [ ! -z "$(which debootstrap)" ]; then
        DEBOOTSTRAP_EXEC=$(which debootstrap)
        ver=$(${DEBOOTSTRAP_EXEC} --version | awk '{print $2}' || /bin/true)
    else
        fatal "there is no debootstrap." \
              "It's recommended to install the latest version of the program" \
              "using its git repo:" \
              "https://anonscm.debian.org/git/d-i/debootstrap.git"
        exit 1
    fi

    if [ -z "${ver}" ]; then
        fatal "your debootstrap seems to be broken. Could not get its version."
        exit 1
    fi

    if dpkg --compare-versions "${ver}" lt "${DEBOOTSTRAP_VER}"; then
        fatal "debootstrap ${DEBOOTSTRAP_VER} or higher is required."
        exit 1
    fi

    info "using ${DEBOOTSTRAP_EXEC}"
}

# Chooses the corresponding user mode emulation binary and assigns its full
# path to the EMULATOR environment variable. The binary depends on the
# architecture of the operating system which is going to be used as a base for
# the target image.
# Globals:
#     EMULATOR
#     PIECES
# Arguments:
#     None
# Returns:
#     None
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
        # shellcheck disable=SC2034
        EMULATOR=/usr/bin/qemu-aarch64-static
        ;;
    *)
        fatal "Unknown architecture ${PIECES[2]}."
        exit 1
    esac
}

# Cleans up the build environment.
# Globals:
#     IMAGE
#     KEYRING
#     LOOP_DEV
#     MOUNT_POINT
#     PROJECT_NAME
# Arguments:
#     None
# Returns:
#     None
cleanup() {
    safe_unmount "${MOUNT_POINT}"

    umount_required_filesystems

    set -x

    rm -f "${FIRSTBOOT}"

    rm -f "${KEYRING}"

    if check_if_variable_is_set LOOP_DEV; then
        losetup -d "${LOOP_DEV}"
    fi

    remove_temporary_dirs

    set +x
}

# Creates an image which has two partitions. The first one is the boot
# partition and the second one is the partition intended for the root
# filesystem.
# Globals:
#     IMAGE
# Arguments:
#     Root filesystem size in bytes
# Returns:
#     None
create_image() {
    # Partitions should be aligned on 4MiB boundaries.
    # See https://lwn.net/Articles/428584/.
    local alignment=4 # in megabytes
    local alignment_x2=$(( alignment * 2 ))

    # The size of the partition which stores the kernel and RPi blobs.
    local boot_partition_size=100 # in megabytes

    # The size of the target image.
    local image_size=0

    # Just in case allocate 10% more space than required.
    # shellcheck disable=SC2155
    local metadata_size="$(python3 -c "import math; print(math.ceil($1 / 10))")"

    # The root partition size should be large enough to fit the rootfs.
    local root_partition_size="$(( $1 + metadata_size ))"

    image_size=$(( root_partition_size + (boot_partition_size + alignment_x2) * 1024 * 1024 ))

    dd if=/dev/zero of="${IMAGE}" bs=1 seek=${image_size} count=1

    parted "${IMAGE}" mktable msdos

    parted "${IMAGE}" mkpart p fat32 4MiB "$(( boot_partition_size + alignment ))MiB"

    parted -s "${IMAGE}" -- mkpart primary ext2 "$(( boot_partition_size + alignment_x2 ))MiB" -1s

    info "${IMAGE} of size ${image_size}K was successfully created"
}

# Checks if the specified OS is Alpine.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_alpine() {
    if [ "${PIECES[0]}" = "alpine" ]; then
        true
    else
        false
    fi
}

# Checks if the specified OS is a Debian derivative.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_debian_based() {
    if [ "${PIECES[0]}" = "devuan" ] || [ "${PIECES[0]}" = "raspbian" ] || [ "${PIECES[0]}" = "ubuntu" ]; then
        true
    else
        false
    fi
}

# Checks if the specified OS is Devuan.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_devuan() {
    if [ "${PIECES[0]}" = "devuan" ]; then
        true
    else
        false
    fi
}

# Checks if the specified OS is Raspbian.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_raspbian() {
    if [ "${PIECES[0]}" = "raspbian" ]; then
        true
    else
        false
    fi
}

# Checks if the specified OS is Ubuntu.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_ubuntu() {
    if [ "${PIECES[0]}" = "ubuntu" ]; then
        true
    else
        false
    fi
}

# Guarantees calling cleanup before exiting with non-zero code.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
do_exit() {
    cleanup

    exit 1
}

# Calls the cleanup function on the following signals: SIGHUP, SIGINT, SIGQUIT
# and SIGABRT.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
set_traps() {
    trap cleanup 1 2 3 6 ERR
}
