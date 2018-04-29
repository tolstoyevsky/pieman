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

# Gets the Alpine Package Keeper version.
# Globals:
#     PIECES
#     PIEMAN_BIN
#     PYTHON
# Arguments:
#     None
# Returns:
#     Version
get_apk_tools_version() {
    ${PYTHON} "${PIEMAN_BIN}"/apk-tools-version.py --alpine-version="${PIECES[1]}"
}

# Gets the latest version of apk.static for the specified Alpine release and
# runs it to build a chroot environment.
# Globals:
#     BASE_PACKAGES
#     BUILD_DIR
#     ETC
#     OS
#     PIECES
#     R
#     PROJECT_NAME
# Arguments:
#     None
# Returns:
#     None
run_apk_static() {
    local apk_tools_version=""
    local apk_tools_static=""
    local primary_repo=""

    apk_tools_version="$(get_apk_tools_version)"
    apk_tools_static="apk-tools-static-${apk_tools_version}.apk"

    primary_repo="$(get_attr "${OS}" repos | head -n1)"

    cd "${BUILD_DIR}/${PROJECT_NAME}" || exit 1
        wget "${primary_repo}/v${PIECES[1]}/main/armhf/${apk_tools_static}" -O "${apk_tools_static}"

        tar -xzf "${apk_tools_static}"

        rm "${apk_tools_static}"
    cd - || exit 1

    mkdir -p "${R}"/usr/bin

    install_user_mode_emulation_binary

    # Ignore SC2086 since BASE_PACKAGES shouldn't be double-quoted.
    # shellcheck disable=SC2086
    "${BUILD_DIR}/${PROJECT_NAME}"/sbin/apk.static -X "${primary_repo}/v${PIECES[1]}/main" -U --allow-untrusted --root "${R}" --initdb add alpine-base ${BASE_PACKAGES}

    echo "nameserver 8.8.8.8" > "${ETC}"/resolv.conf
}