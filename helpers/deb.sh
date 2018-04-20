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

# Runs the first stage of building a chroot environment. Then it installs
# a user mode emulation binary to the chroot.
# Globals:
#     BASE_PACKAGES
#     DEBOOTSTRAP_EXEC
#     OS
#     PIECES
#     KEYRING
# Arguments:
#     None
# Returns:
#     None
run_first_stage() {
    local additional_opts=""

    if [ ! -z ${BASE_PACKAGES} ]; then
        additional_opts="--include=${BASE_PACKAGES}"
    fi

    arch=${PIECES[2]}
    codename=${PIECES[1]}
    primary_repo=`get_attr ${OS} repos | head -n1`
    ${DEBOOTSTRAP_EXEC} --arch=${arch} --foreign --variant=minbase --keyring=${KEYRING} ${additional_opts} ${codename} ${R} ${primary_repo} 1>&2

    install_user_mode_emulation_binary
}

# Runs the second (i.e. final) stage of building a chroot environment.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
run_second_stage() {
    chroot_exec debootstrap/debootstrap --second-stage
}
