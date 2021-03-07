# Copyright (C) 2019 Evgeny Golyshev <eugulixes@gmail.com>
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

# Checks if the Das U-Boot dependencies are satisfied.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     0 or 1 depending on the result.
are_uboot_dependencies_satisfied() {
    local ret=0

    >&2 echo -n "checking /usr/include/python2.7/Python.h... "
    yes_or_no "[ -f /usr/include/python2.7/Python.h ]" || ret=1

    >&2 echo -n "checking bison... "
    yes_or_no "[ ! -z $(command -v bison) ]" || ret=1

    >&2 echo -n "checking cc... "
    yes_or_no "[ ! -z $(command -v cc) ]" || ret=1

    >&2 echo -n "checking flex... "
    yes_or_no "[ ! -z $(command -v flex) ]" || ret=1

    >&2 echo -n "checking git... "
    yes_or_no "[ ! -z $(command -v git) ]" || ret=1

    >&2 echo -n "checking make... "
    yes_or_no "[ ! -z $(command -v make) ]" || ret=1

    >&2 echo -n "checking python2... "
    yes_or_no "[ ! -z $(command -v python2) ]" || ret=1

    >&2 echo -n "checking swig... "
    yes_or_no "[ ! -z $(command -v swig) ]" || ret=1

    # Required by the toolchain which is going to be used for building U-Boot.
    >&2 echo -n "checking xz... "
    yes_or_no "[ ! -z $(command -v xz) ]" || ret=1

    return "${ret}"
}

# Installs SPL (secondary program loader) if it's specified in pieman.yml.
# Globals:
#     LOOP_DEV
# Arguments:
#     None
# Returns:
#     None
install_spl() {
    spl_bin="$(get_attr_or_nothing spl_bin)"
    if [[ -n ${spl_bin} ]]; then
        dd if="${spl_bin}" of="${LOOP_DEV}" bs=1024 seek=8
        sync
    fi
}
