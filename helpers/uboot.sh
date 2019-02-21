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

# Checks if the U-Boot dependencies are satisfied.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     0 or 1 depending on the result.
are_uboot_dependencies_satisfied() {
    local ret=0

    >&2 echo -n "checking bison... "
    yes_or_no "[ ! -z $(which bison) ]" || ret=1

    >&2 echo -n "checking flex... "
    yes_or_no "[ ! -z $(which flex) ]" || ret=1

    >&2 echo -n "checking make... "
    yes_or_no "[ ! -z $(which make) ]" || ret=1

    >&2 echo -n "checking mkimage... "
    yes_or_no "[ ! -z $(which mkimage) ]" || ret=1

    return "${ret}"
}
