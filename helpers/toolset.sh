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

# Removes
# * the specified files and directories;
# * the .partial file in the current directory.
# Globals:
#     None
# Arguments:
#     Target directory
# Returns:
#     None
finalise_installation() {
    for i in "$@"; do
        rm -rf "${i}"
    done

    rm -f .partial
}

# Gets qemu-user-static 3.1 from Ubuntu 19.04 "Disco Dingo".
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
get_qemu_emulation_binary() {
    local package
    
    wget http://mirrors.kernel.org/ubuntu/dists/disco/universe/binary-amd64/Packages.xz

    xz -d Packages.xz

    package="$(grep "Filename: pool/universe/q/qemu/qemu-user-static" Packages | awk '{print $2}')"

    wget http://security.ubuntu.com/ubuntu/"${package}"

    ar x "$(basename "${package}")"

    tar xJf data.tar.xz

    cp usr/bin/qemu-aarch64-static .
    cp usr/bin/qemu-arm-static .

    # cleanup
    rm    control.tar.xz
    rm    data.tar.xz
    rm    debian-binary
    rm    Packages
    rm    "$(basename "${package}")"
    rm -r usr
}

# Checks if the specified Toolset component is partially installed, and if so,
# cleans up its directory and initializes it for the installation, creating the
# .partial file there.
# Globals:
#     None
# Arguments:
#     Target directory
# Returns:
#     0 if the specified component directory was initialized
#     1 if there was no need to initialize the specified component directory
init_installation_if_needed() {
    local dir=$1

    create_dir "${dir}"
    if [ -z "$(ls -A "${dir}")" ] || [ -f "${dir}"/.partial ]; then
        rm -rf "${dir:?}"/*

        touch "${dir}"/.partial

        return 0
    fi

    return 1
}

# Figures out the number of CPU cores which are available on the current
# machine.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     Number of available cores
number_of_cores() {
    grep -c ^processor /proc/cpuinfo
}
