# Copyright (C) 2019 Denis Gavrilyuk <karpa4o4@gmail.com>
# Copyright (C) 2019-2020 Evgeny Golyshev <eugulixes@gmail.com>
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

# Encrypts the specified password using the SHA-512 method.
# Globals:
#     PYTHON
# Arguments:
#     Password
# Returns:
#     Encrypted password
do_mkpasswd() {
    "${PYTHON}" -c "import crypt; print(crypt.crypt('$1', crypt.mksalt(crypt.METHOD_SHA512)))"
}

# Downloads files from the Web non-interactively.
# Globals:
#     None
# Arguments:
#     wget options (only -O and -q are supported)
#     URL
# Returns:
#     None
do_wget() {
    wget.py "$@"
}

