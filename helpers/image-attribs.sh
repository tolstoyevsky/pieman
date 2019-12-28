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

# Gets the values the specified image attribute using image_attrs.py. If its
# exit code is different from 0, interrupt the execution of the script and
# exit.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
#     YML_FILE
# Arguments:
#     Image attribute
# Returns:
#     Image attribute value
get_attr() {
    local output=""

    { output="$("${PYTHON}" "${PIEMAN_UTILS_DIR}"/image_attrs.py --file="${YML_FILE}" "$@" 2>&1)"; exit_code="$?"; } || true
    if [ "${exit_code}" -ne 0 ]; then
        fatal "while getting the specified attribute from ${YML_FILE}" \
              "occurred the following error: ${output}."
        do_exit
    fi

    echo "${output}"
}

# Gets the values the specified image attribute using image_attrs.py.
# If image_attrs.py could not succeed, the function does nothing.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
#     YML_FILE
# Arguments:
#     Image attribute
# Returns:
#     Image attribute value
get_attr_or_nothing() {
    "${PYTHON}" "${PIEMAN_UTILS_DIR}"/image_attrs.py --file="${YML_FILE}" "$@" 2> /dev/null || /bin/true
}
