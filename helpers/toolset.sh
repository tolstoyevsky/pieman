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

build_toolset() {
    build_toolset.py ${PIEMAN_DIR}/.toolset.yml
}

# Runs the preprocessor against toolset.yml, located in the root directory of
# Pieman.
# Globals:
#     PIEMAN_DIR
#     PIEMAN_UTILS_DIR
#     PYTHON
# Arguments:
#     None
# Returns:
#     None
run_preprocessor_against_toolset_yml() {
    preprocessor.py ${PIEMAN_DIR}/toolset.yml ${PIEMAN_DIR}/.toolset.yml
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
    
    do_wget http://mirrors.kernel.org/ubuntu/dists/focal/universe/binary-amd64/Packages.xz

    xz -d Packages.xz

    package="$(grep "Filename: pool/universe/q/qemu/qemu-user-static" Packages | awk '{print $2}')"

    do_wget http://security.ubuntu.com/ubuntu/"${package}"

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
