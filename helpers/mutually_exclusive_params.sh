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

# Checks if two or more mutually exclusive parameters are set true or does not
# contain an empty string.
# Globals:
#     None
# Arguments:
#     Parameters
# Returns:
#     None
check_mutually_exclusive_params() {
    for a in "$@"; do
        for b in "$@"; do
            if [[ "${a}" == "${b}" ]]; then
                continue
            fi
            if ! ${PYTHON} "${PIEMAN_UTILS_DIR}"/check_mutually_exclusive_params.py "${a}" "${b}"; then
                fatal "${a} and ${b} conflict with each other."
                exit 1
            fi
        done
    done
}