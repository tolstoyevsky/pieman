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

# Adds the specified package name to the BASE_PACKAGES environment variable
# which is a comma-separated list.
# Globals:
#     BASE_PACKAGES
# Arguments:
#     Package name
# Returns:
#     None
add_package_to_base_packages() {
    add_item_to_list "${1}" BASE_PACKAGES ","
}

# Adds the specified package name to the INCLUDES environment variable which is
# a comma-separated list.
# Globals:
#     INCLUDES
# Arguments:
#     Package name
# Returns:
#     None
add_package_to_includes() {
    add_item_to_list "${1}" INCLUDES ","
}

# Adds the specified options to the PM_OPTIONS environment variable which is
# a space-separated list.
# Globals:
#     PM_OPTIONS
# Arguments:
#     option
# Returns:
#     None
add_option_to_pm_options() {
    add_item_to_list "${1}" PM_OPTIONS " "
}

# Creates a keyring from the public keys related to the operating system which
# is going to be used as a base for the target image. Then, the keyring is
# passed to debootstrap. The keyring name is stored in the KEYRING environment
# variable.
# Globals:
#     PIECES
#     KEYRING
# Arguments:
#     None
# Returns:
#     None
create_keyring() {
    for key in keys/${PIECES[0]}/*; do
        gpg --no-default-keyring --keyring="${KEYRING}" --import "${key}"
    done
}

# Adds the public keys, related to the operating system which is used as a base
# for the target image, to the list of trusted keys.
# Globals:
#     PIECES
#     R
# Arguments:
#     None
# Returns:
#     None
mark_keys_as_trusted() {
    for key in keys/${PIECES[0]}/*; do
        local key_name=""

        key_name=$(basename "${key}")

        cp "${key}" "${R}"

        info "adding ${key} to the list of trusted keys"
        chroot_exec apt-key add "${key_name}"

        chroot_exec rm "${key_name}"
    done
}
