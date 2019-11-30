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

build_toolset() {
    build_toolset.py ${PIEMAN_DIR}/.toolset.yml
}

# Runs the preprocessor against toolset.yml, located in the root directory of
# Pieman.
# Globals:
#     PIEMAN_DIR
#     PIEMAN_UTILS_DIR
#     PYTHON
# Arguments:
#     None
# Returns:
#     None
run_preprocessor_against_toolset_yml() {
    preprocessor.py ${PIEMAN_DIR}/toolset.yml ${PIEMAN_DIR}/.toolset.yml
}

