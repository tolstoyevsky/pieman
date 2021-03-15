# Copyright (C) 2019-2021 Evgeny Golyshev <eugulixes@gmail.com>
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

# Mocks the debootstrap executable, storing the arguments passed to it to be
# checked later.
# Globals:
#     DEBOOTSTRAP_CMD_LINE
# Arguments:
#     deboostrap arguments
# Returns:
#     None
debootstrap_mock() {
    # appears unused
    # shellcheck disable=SC2034
    DEBOOTSTRAP_CMD_LINE=$*
}

# Mocks install_user_mode_emulation_binary. The origianl function is invoked by
# run_first_stage and changes the rootfs of the target image. When
# run_first_stage is tested, install_user_mode_emulation_binary must do
# nothing.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
install_user_mode_emulation_binary() {
    true
}
