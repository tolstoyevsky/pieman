# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
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

check_if_variable_is_set ENABLE_USER PASSWORD USER_NAME USER_PASSWORD

if ${ENABLE_USER}; then
    info "creating regular user ${USER_NAME}"
    add_user "${USER_NAME}" "${USER_PASSWORD}"

    if ${ENABLE_SUDO}; then
        info "add regular user ${USER_NAME} to /etc/sudoers"

        if ${SUDO_REQUIRE_PASSWORD}; then
            permission="ALL=(ALL:ALL) ALL"
        else
            permission="ALL=(ALL) NOPASSWD: ALL"
        fi

        echo "${USER_NAME} ${permission}" > "${ETC}"/sudoers.d/01_allow_executing_any_command
    fi
fi

info "setting root password"
set_root_password "${PASSWORD}"

send_request_to_bsc_server DONE_WITH_USERS_CODE
