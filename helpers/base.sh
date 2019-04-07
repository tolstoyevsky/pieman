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
#     COMPRESS_WITH_XZ
#     PIEMAN_MAJOR_VER
#     PIEMAN_MINOR_VER
#     PYTHON
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
# Globals:
#     None
# Arguments:
#     Parameters
# Returns:
#     None
check_mutually_exclusive_params() {
    for a in "$@"; do
        for b in "$@"; do
            if [[ "${a}" == "${b}" ]]; then
                continue
            fi
            if ! ${PYTHON} "${PIEMAN_UTILS_DIR}"/check_mutually_exclusive_params.py "${a}" "${b}"; then
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
#     PYTHON
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
#     PYTHON
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
#     FIRSTBOOT
#     KEYRING
#     LOOP_DEV
#     MOUNT_POINT
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

# Creates an image with the specified number of partitions.
# When the partition size are specified, it's possible to additionally specify
# a type of each partition. For example,
#   create_image 4 fat32:100 1024
# In this case, there are an alignment equal to 4M and two partitions one of
# which marked as "W95 FAT32 (LBA)" (partition type 0xc). If a label of a
# partition is not explicitly mentioned, it considered as "Linux" by default
# (partition type 0x83).
# Partition type can take one of the values mentioned in the documentation
# related to the mkpart command
# (see https://gnu.org/software/parted/manual/html_node/mkpart.html)
# Globals:
#     IMAGE
# Arguments:
#     Alignment size in megabytes
#     Partition1 size in megabytes
#     PartitionN size in megabytes
#     ...
# Returns:
#     Image size in megabytes
create_image() {
    local alignment=$1
    local args=("${@:2}")
    local default_fs_type="ext4"
    local fs_types=()
    local image_size="${alignment}"
    local partition_sizes=()

    local latest
    local start
    local end

    # Parse arguments of the function and figure out the size of the image.
    for partition in "${args[@]}"; do
        local butter_bread=()
        local fs_type=""
        local partition_size=0

        IFS=':' read -ra butter_bread <<< "${partition}"
        if [ "${#butter_bread[@]}" -gt 1 ]; then
            fs_type="${butter_bread[0]}"
            partition_size="${butter_bread[1]}"
        else
            fs_type="${default_fs_type}"
            partition_size="${butter_bread[0]}"
        fi

        fs_types+=("${fs_type}")
        partition_sizes+=("${partition_size}")

        image_size=$((image_size + partition_size))
    done

    # Create the image.

    dd if=/dev/zero of="${IMAGE}" bs="$((1024 * 1024))" seek="${image_size}" count=1

    parted "${IMAGE}" mktable msdos

    latest="$((${#fs_types[@]} - 1))"
    start="${alignment}"
    for i in $(seq 0 "${latest}"); do
        end="$((start + partition_sizes[i]))"

        if [ "${i}" == "${latest}" ]; then
            parted -s "${IMAGE}" -- mkpart primary "${fs_types[i]}" "${start}MiB" -1s
        else
            parted "${IMAGE}" mkpart p "${fs_types[i]}" "${start}MiB" "${end}MiB"
        fi

        start="${end}"
    done

    echo "${image_size}"
}

# Formats the the partitions of the image. The number of the specified
# filesystem types should match the number of the partitions in the image.
# The supported filesystem types are fat (or vfat) and ext4.
# Globals:
#     LOOP_DEV
# Arguments:
#     Filesystem type1
#     Filesystem typeN
#     ...
# Returns:
#     None
format_partitions() {
    local args=("$@")
    local mkfs=""

    for i in $(eval echo "{1..$#}"); do
        mkfs="mkfs.${args[i - 1]}"
        case "${args[i - 1]}" in
        fat|vfat)
            local volume_name=""
            if [[ "${i}" -eq 1 ]]; then
                # If the first partition is FAT, give volume name boot to it.
                volume_name="-n boot"
            fi

            # shellcheck disable=SC2086
            ${mkfs} ${volume_name} -F 32 -v "${LOOP_DEV}p${i}" 1>&2-
            ;;
        ext4)
            ${mkfs} "${LOOP_DEV}p${i}" 1>&2-
            ;;
        *)
            fatal "unknown filesystem type"
            exit 1
            ;;
        esac
    done
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
    if [ "${PIECES[0]}" = "debian" ] || [ "${PIECES[0]}" = "devuan" ] || [ "${PIECES[0]}" = "kali" ] || [ "${PIECES[0]}" = "raspbian" ] || [ "${PIECES[0]}" = "ubuntu" ]; then
        true
    else
        false
    fi
}

# Checks if the specified OS is Debian.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_debian() {
    if [ "${PIECES[0]}" = "debian" ]; then
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

# Checks if the specified OS is Kali.
# Globals:
#     PIECES
# Arguments:
#     None
# Returns:
#     Boolean
is_kali() {
    if [ "${PIECES[0]}" = "kali" ]; then
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

# Creates loop device and scans partition table.
# Globals:
#     IMAGE
#     LOOP_DEV
# Arguments:
#     None
# Returns:
#     None
scan_partition_table() {
    LOOP_DEV=$(losetup --partscan --show --find "${IMAGE}")
    partition1="${LOOP_DEV}p1"

    # It may take a while until devices appear in /dev.
    max_retries=30
    for i in $(eval echo "{1..${max_retries}}"); do
        if [ -z "$(ls "${partition1}" 2> /dev/null)" ]; then
            info "there is no ${partition1} so far ($((max_retries - i)) attempts left)"
            sleep 1
        else
            break
        fi
    done

    if [ -z "$(ls "${partition1}" 2> /dev/null)" ]; then
        fatal "${partition1} does not exist"
        do_exit
    fi
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
    trap "cleanup && send_request_to_bsc_server FAILED_CODE && stop_bscd && exit 130" 2
    trap "cleanup && send_request_to_bsc_server FAILED_CODE && stop_bscd" 1 3 6 ERR
}

# Splits the value of the OS variable into pieces and stores it to the PIECES
# array. OS must stick to the following naming convention:
# <distro name>-<codename>-<arch>.
# Globals:
#     None
# Arguments:
#     OS
#     PIECES
# Returns:
#     None
split_os_name_into_pieces() {
    # shellcheck disable=SC2034
    IFS='-' read -ra PIECES <<< "${OS}"
    codename="$(get_attr_or_nothing "${OS}" codename)"
    if [ ! -z "${codename}" ]; then
        PIECES[1]="${codename}"
    fi
}
