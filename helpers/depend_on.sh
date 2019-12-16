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

# Checks if the dependency environment variables are set to true (if bool) or
# simply specified (in other cases) when the dependent environment variable is
# set to true (if bool) or simply specified (in other cases).
# Globals:
#     None
# Arguments:
#     Dependent parameter
#     Dependency parameter1
#     Dependency parameterN
#     ...
# Returns:
#     0 or None in case of success
depend_on() {
    local var=$1

    if ! check_if_variable_is_set "$1"; then
        return 0
    fi

    for dependency in "$@"; do
        if [[ "${var}" == "${dependency}" ]]; then
            continue
        fi

        if ! ${PYTHON} "${PIEMAN_UTILS_DIR}"/depend_on.py "${var}" "${dependency}"; then
            fatal "${var} depends on ${dependency}, so the latter must be set to true (if bool) or simply specified (in other cases)."
            exit 1
        fi
    done
}