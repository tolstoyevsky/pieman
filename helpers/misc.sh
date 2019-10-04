# Copyright (C) 2019 Denis Gavrilyuk <karpa4o4@gmail.com>
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

# Downloads files from the Web non-interactively.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
# Arguments:
#     wget options (only -O and -q are supported)
#     URL
# Returns:
#     None
do_wget() {
    ${PYTHON} "${PIEMAN_UTILS_DIR}"/wget.py "$@"
}
