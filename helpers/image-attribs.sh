# Copyright (C) 2018-2021 Evgeny Golyshev <eugulixes@gmail.com>
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

# Gets the values the specified image attribute using image_attrs.py. If its
# exit code is different from 0, interrupt the execution of the script and
# exit.
# Globals:
#     OS
#     YML_FILE
# Arguments:
#     Image attribute
# Returns:
#     Image attribute value
get_attr() {
    local output=""

    if ! output=$(preprocessor.py "${YML_FILE}" "${OS}" | image_attrs.py "${OS}" "$@" 2>&1); then
        fatal "while getting the specified attribute from ${YML_FILE}" \
              "occurred the following error: ${output}."
        do_exit
    fi

    echo "${output}"
}

# Gets the values the specified image attribute using image_attrs.py.
# If image_attrs.py could not succeed, the function does nothing.
# Globals:
#     OS
#     YML_FILE
# Arguments:
#     Image attribute
# Returns:
#     Image attribute value
get_attr_or_nothing() {
    preprocessor.py "${YML_FILE}" "${OS}" | image_attrs.py "${OS}" "$@" 2> /dev/null || /bin/true
}
