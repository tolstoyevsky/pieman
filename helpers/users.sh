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

# Adds a regular user with the specified password to the target system.
# Globals:
#     None
# Arguments:
#     Username
#     Password
# Returns:
#     None
add_user() {
    local encrypted_password=""
    local username=$1
    local password=$2

    if is_alpine; then
        chroot_exec adduser -h "/home/${username}" -s /bin/sh "${username}" << EOF
${password}
${password}
EOF
    elif is_debian_based; then
        chroot_exec useradd -m "${username}" -s /bin/bash

        encrypted_password="$(mkpasswd -m sha-512 "${password}")"

        chroot_exec usermod -p "${encrypted_password}" "${username}"
    fi
}

# Sets the root password in the target system.
# Globals:
#     None
# Arguments:
#     Password
# Returns:
#     None
set_root_password() {
    local encrypted_password=""
    local password=$1

    if is_alpine; then
        chroot_exec passwd << EOF
${password}
${password}
EOF
    elif is_debian_based; then
        encrypted_password="$(mkpasswd -m sha-512 "${password}")"

        chroot_exec usermod -p "${encrypted_password}" root
    fi
}