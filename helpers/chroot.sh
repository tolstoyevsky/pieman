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

# Create a chroot environment based on one of the supported operating systems.
# Globals:
#     SOURCE_DIR
# Arguments:
#     None
# Returns:
#     None
create_chroot_environment() {
    run_scripts "${SOURCE_DIR}"/pre-create-chroot

    if is_alpine; then
        run_apk_static
    elif is_debian_based; then
        create_keyring

        run_scripts "${SOURCE_DIR}"/pre-first-stage

        run_first_stage

        run_scripts "${SOURCE_DIR}"/post-first-stage

        run_scripts "${SOURCE_DIR}"/pre-second-stage

        run_second_stage

        run_scripts "${SOURCE_DIR}"/post-second-stage

        # To prevent NO_PUBKEY when the packages will be installed a bit later.
        mark_keys_as_trusted
    fi

    run_scripts "${SOURCE_DIR}"/post-create-chroot
}

# Executes the specified command in the chroot environment.
# Globals:
#     R
# Arguments:
#     Command line to be passed to the chroot environment
# Returns:
#     None
chroot_exec() {
    chroot "${R}" "$@" 1>&2
}

# Executes the specified command in the chroot environment using shell.
# Globals:
#     R
# Arguments:
#     Command line to be passed to the chroot environment
# Returns:
#     None
chroot_exec_sh() {
    chroot "${R}" sh -c "$@" 1>&2
}
