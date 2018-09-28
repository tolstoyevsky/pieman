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

# Declares the DEBOOTSTRAP_EXEC environment variable which then can be used to
# execute debootstrap.
# Globals:
#     DEBOOTSTRAP_DIR
#     DEBOOTSTRAP_EXEC
#     DEBOOTSTRAP_VER
# Arguments:
#     None
# Returns:
#     None
init_debootstrap() {
    local path_to_debootstrap="${TOOLSET_DIR}/debootstrap"
    local ver=""

    DEBOOTSTRAP_EXEC="env DEBOOTSTRAP_DIR=${path_to_debootstrap} ${path_to_debootstrap}/debootstrap"

    info "using ${DEBOOTSTRAP_EXEC}"
}

# Checks if debootstrap is equal to or higher than the version specified in the
# DEBOOTSTRAP_VER environment variable.
# Globals:
#     DEBOOTSTRAP_VER
#     PIEMAN_DIR
#     TOOLSET_DIR
# Arguments:
#     None
# Returns:
#     Boolean
is_debootstrap_uptodate() {
    local path_to_debootstrap="${TOOLSET_DIR}/debootstrap"

    # After cloning the debootstrap git repo the program is a fully
    # functional, but does not have a correct version number. However, the
    # version can be found in the source package changelog.
    ver=$(sed 's/.*(\(.*\)).*/\1/; q' "${path_to_debootstrap}"/debian/changelog)

    if [ -z "${ver}" ]; then
        fatal "your debootstrap seems to be broken. Could not get its version."
        exit 1
    fi

    if dpkg --compare-versions "${ver}" lt "${DEBOOTSTRAP_VER}"; then
        false
    else
        true
    fi
}

# Runs the first stage of building a chroot environment based on a Debian-based
# distribution. Then it installs a user mode emulation binary to the chroot.
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

    if [ ! -z "${BASE_PACKAGES}" ]; then
        additional_opts="--include=${BASE_PACKAGES}"
    fi

    arch=${PIECES[2]}
    codename=${PIECES[1]}
    primary_repo=$(get_attr "${OS}" repos | head -n1)
    # shellcheck disable=SC2086
    ${DEBOOTSTRAP_EXEC} --arch="${arch}" --foreign --variant=minbase --keyring="${KEYRING}" ${additional_opts} ${codename} "${R}" "${primary_repo}" 1>&2

    install_user_mode_emulation_binary
}

# Runs the second (i.e. final) stage of building a chroot environment based on
# a Debian-based distribution.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
run_second_stage() {
    chroot_exec debootstrap/debootstrap --second-stage
}
