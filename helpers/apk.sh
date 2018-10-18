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

# Gets the Alpine Package Keeper (APK) version for the specified version of
# Alpine Linux.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
# Arguments:
#     Version of Alpine Linux
# Returns:
#     Alpine Package Keeper version
get_apk_tools_version() {
    local alpine_version=$1

    ${PYTHON} "${PIEMAN_UTILS_DIR}"/apk-tools-version.py --alpine-version="${alpine_version}"
}

# Runs apk.static to build a chroot environment.
# Globals:
#     BASE_PACKAGES
#     ETC
#     OS
#     PIECES
#     R
#     TOOLSET_DIR
# Arguments:
#     None
# Returns:
#     None
run_apk_static() {
    local primary_repo

    primary_repo="$(get_attr "${OS}" repos | head -n1)"

    mkdir -p "${R}"/usr/bin

    install_user_mode_emulation_binary

    # Ignore SC2086 since BASE_PACKAGES shouldn't be double-quoted.
    # shellcheck disable=SC2086
    "${TOOLSET_DIR}/apk/${PIECES[1]}/apk.static" -X "${primary_repo}/v${PIECES[1]}/main" -U --allow-untrusted --root "${R}" --initdb add alpine-base ${BASE_PACKAGES}

    echo "nameserver 8.8.8.8" > "${ETC}"/resolv.conf
}