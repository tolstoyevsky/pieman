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

# Clears out the local repository of retrieved package files and removes
# indexes.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
clean() {
    if is_alpine; then
        rm -rf "${R}"/var/cache/apk/*
    elif is_debian_based; then
        chroot_exec apt-get clean
        rm -rf "${R}"/var/lib/apt/lists/*
    fi
}

# Updates the indexes in the chroot environment.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
update_indexes() {
    if is_alpine; then
        chroot_exec apk update
    elif is_debian_based; then
        chroot_exec apt-get update
    fi
}

# Upgrades the chroot environment.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
upgrade() {
    if is_alpine; then
        # shellcheck disable=SC2086
        chroot_exec apk upgrade ${PM_OPTIONS}
    elif is_debian_based; then
        # shellcheck disable=SC2086
        chroot_exec apt-get -y ${PM_OPTIONS} dist-upgrade
    fi
}

# Installs the specified packages in the chroot environment.
# Globals:
#     None
# Arguments:
#     Packages names, separated by spaces
# Returns:
#     None
install_packages() {
    if is_alpine; then
        # shellcheck disable=SC2086
        chroot_exec apk add ${PM_OPTIONS} "$@"
    elif is_debian_based; then
        if ${ENABLE_UNATTENDED_INSTALLATION}; then
            DEBIAN_FRONTEND=noninteractive chroot_exec apt-get -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "${PM_OPTIONS}" install "$@"
        else
            # shellcheck disable=SC2086
            chroot_exec apt-get -y ${PM_OPTIONS} install "$@"
        fi
    fi
}

# Removes the specified packages with their configuration files from the chroot
# environment.
# Globals:
#     None
# Arguments:
#     Packages names, separated by spaces
# Returns:
#     None
purge_packages() {
    if is_alpine; then
        chroot_exec apk del "$@"
    elif is_debian_based; then
        chroot_exec apt-get -y purge "$@"
    fi
}
