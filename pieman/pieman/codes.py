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

"""Module intended for parsing the build_status_codes text file. """

import os
import sys


BUILD_STATUS_CODES = os.path.join(os.path.dirname(__file__),
                                  'build_status_codes')

MODULE = sys.modules[__name__]

LINES = [line.rstrip('\n').strip() for line in open(BUILD_STATUS_CODES)]
for line in LINES:
    if line and not line.startswith('#'):
        nam, val = line.split('=')
        setattr(MODULE, nam, val.encode())  # values must be bytes
