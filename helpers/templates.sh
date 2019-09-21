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

# Renders Jinja2 templates.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
# Arguments:
#     Template to be rendered
#     Result path
# Returns:
#     None
render() {
    local error_msg="rendering error: "
    local template_path=$1
    local result_path=$2

    { ${PYTHON} "${PIEMAN_UTILS_DIR}"/render.py "${template_path}" "${result_path}"; exit_code="$?"; } || true
    case "${exit_code}" in
    0)
        ;;
    1)
        fatal "${error_msg}${template_path} does not exist"
        exit 1
        ;;
    2)
        fatal "${error_msg}$(dirname "${result_path}") does not exist"
        exit 1
        ;;
    *)
        fatal "unknown error"
        exit 1
        ;;
    esac
}
