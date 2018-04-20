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

# Executes the specified command in the chroot environment.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
chroot_exec() {
    chroot "${R}" "$@" 1>&2
}

# Executes the specified command in the chroot environment using shell.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
chroot_exec_sh() {
    chroot "${R}" sh -c "$@" 1>&2
}
