# Copyright (C) 2020 Evgeny Golyshev <eugulixes@gmail.com>
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

"""Toolset module intended for fetching qemu-user-static the Ubuntu archive. """

from pieman import util


FLAVOURS_ENABLED = True

REQUIRED_FIELDS = ('arch', 'codename', 'dst', )

UBUNTU_CODENAME = 'focal'


def run(*args, **kwargs):
    exit_code = util.run_program(['get-qemu-user-static.sh', UBUNTU_CODENAME])
    print(f'----- {exit_code}')
