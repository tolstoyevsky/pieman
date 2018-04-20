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
    chroot_exec apt-get clean
    rm -rf ${R}/var/lib/apt/lists/*
}

# Updates the indexes in the chroot environment.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
update_indexes() {
    chroot_exec apt-get update
}

# Upgrades the chroot environment.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
upgrade() {
    chroot_exec apt-get -y ${PM_OPTIONS} dist-upgrade
}

# Installs the specified packages in the chroot environment.
# Globals:
#     None
# Arguments:
#     Packages names, separated by spaces
# Returns:
#     None
install_packages() {
    if ${ENABLE_UNATTENDED_INSTALLATION}; then
        DEBIAN_FRONTEND=noninteractive chroot_exec apt-get -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ${PM_OPTIONS} install $*
    else
        chroot_exec apt-get -y ${PM_OPTIONS} install $*
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
    chroot_exec apt-get -y purge $*
}
