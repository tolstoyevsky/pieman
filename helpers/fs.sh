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

# Calculates the size of the specified directory.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
# Arguments:
#     Directory name
#     Options to be passed to du.py
# Returns:
#     Total size of the specified directory in bytes
calc_size() {
    local dir=$1
    local block_size=""
    local opts=$2

    block_size="$(grep "blocksize" /etc/mke2fs.conf | head -n1 | cut -d'=' -f2 | xargs)"

    # shellcheck disable=SC2086
    "${PYTHON}" "${PIEMAN_UTILS_DIR}"/du.py --block-size="${block_size}" ${opts} "${dir}" | grep "Total size" | cut -d':' -f2 | xargs
}

# Checks if the required directories exist.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
check_required_directories() {
    dirs="bootstrap devices"

    for dir in ${dirs}; do
        if [ ! -d "${dir}" ] ; then
            fatal "${dir} required directory not found!"
            do_exit
        fi
    done
}

# Checks if the required files exist.
# Globals:
#     YML_FILE
# Arguments:
#     None
# Returns:
#     None
check_required_files() {
    if [ ! -f "${YML_FILE}" ]; then
        fatal "${YML_FILE} does not exist"
        do_exit
    fi
}

# Creates the specified directory if it does not exist.
# Globals:
#     None
# Arguments:
#     Directory name
# Returns:
#     None
create_dir() {
    local dir=$1

    if [ ! -d "${dir}" ]; then
        mkdir -p "${dir}"
    fi
}

# Creates the temporary directories used while creating an image.
# Globals:
#     BUILD_DIR
#     CREATE_ONLY_CHROOT
#     IMAGE_OWNERSHIP
#     PROJECT_NAME
# Arguments:
#     None
# Returns:
#     None
create_temporary_dirs() {
    local target=${BUILD_DIR}/${PROJECT_NAME}
    if [ -d "${target}" ]; then
        fatal "${target} already exists"
        do_eixt
    fi

    create_dir "${target}"
    chown "${IMAGE_OWNERSHIP}" "${BUILD_DIR}"
    if ! ${CREATE_ONLY_CHROOT}; then
        create_dir "${target}"/boot
        create_dir "${target}"/mount_point
    fi
}

# Removes temporary directories.
# Globals:
#     BUILD_DIR
#     CREATE_ONLY_CHROOT
#     PROJECT_NAME
# Arguments:
#     None
# Returns:
#     None
remove_temporary_dirs() {
    local target=${BUILD_DIR}/${PROJECT_NAME}

    if ! ${CREATE_ONLY_CHROOT}; then
        rm -rf "${target}"
    fi
}

# Installs the specified file to the specified directory and changes
# the permissions of the file to 744.
# Globals:
#     None
# Arguments:
#     Path to the file
#     Path to the directory
# Returns:
#     None
install_exec() {
    install -o root -g root -m 744 "$@"
}

# Installs the specified file to the specified directory and changes
# the permissions of the file to 644.
# Globals:
#     None
# Arguments:
#     Path to the file
#     Path to the directory
# Returns:
#     None
install_readonly() {
    install -o root -g root -m 644 "$@"
}

# Installs the corresponding user mode emulation binary to the chroot
# environment.
# Globals:
#     EMULATOR
#     USR_BIN
# Arguments:
#     None
# Returns:
#     None
install_user_mode_emulation_binary() {
    # It's not possible to use install_exec for installing user mode emulation
    # binaries. For details, see https://github.com/drtyhlpr/rpi23-gen-image/pull/85.
    install -m 755 -o root -g root "${EMULATOR}" "${USR_BIN}"
}

# Mounts the required filesystems to the chroot environment.
# Globals:
#     R
# Arguments:
#     None
# Returns:
#     None
mount_required_filesystems() {
    mount -t proc none "${R}/proc"
    mount -t sysfs none "${R}/sys"

    # To prevent:
    # /usr/bin/apt-key: cannot create /dev/null: Permission denied
    mount --bind /dev "${R}/dev"

    # To prevent:
    # E: Can not write log (Is /dev/pts mounted?) - posix_openpt (19: No such device)
    if [ -d "${R}/dev/pts" ] ; then
        mount --bind /dev/pts "${R}/dev/pts"
    fi

    # To prevent the following error message:
    # Couldn't create temporary file /tmp/apt.conf.xxxxxx for passing config to apt-key
    mount --bind /tmp "${R}/tmp"
}

# Unmounts the required filesystems checking before if the specified directory
# is a mount point. If the process of unmounting fails, the function tries to
# repeat it a few more times.
# Globals:
#     None
# Arguments:
#     Directory name
# Returns:
#     None
safe_unmount() {
    local max_retries=5
    local mount_point=$1

    if ! mount | grep -q "${mount_point}"; then
        info "${mount_point} is not a mount point"

        return 0
    else
        info "unmounting ${mount_point}"
    fi

    for i in $(eval echo "{1..${max_retries}}"); do
        umount "${mount_point}"

        if ! mount | grep -q "${mount_point}"; then
            return 0
        else
            info "failed to unmount ${mount_point} ($((max_retries - i)) attempts left)"
            sleep 1
        fi
    done

    if ! mount | grep -q "${mount_point}"; then
        fatal "could not unmount ${mount_point} even after ${max_retries} attempts"
    fi
}

# Unmounts the required filesystems.
# Globals:
#     R
# Arguments:
#     None
# Returns:
#     None
umount_required_filesystems() {
    safe_unmount "${R}/proc"

    safe_unmount "${R}/sys"

    safe_unmount "${R}/dev/pts"

    safe_unmount "${R}/dev"

    safe_unmount "${R}/tmp"
}
