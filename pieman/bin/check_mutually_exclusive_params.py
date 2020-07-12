#!/usr/bin/env python3
# Copyright (C) 2018 Denis Gavrilyuk <karpa4o4@gmail.com>
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

"""Utility intended for checking if two specified environment variables are
defined. If so, the utility exits with a non-zero code. Otherwise it exits
normally.
"""

import argparse
import os
import sys


def main():
    """The main entry point. """

    parser = argparse.ArgumentParser()
    parser.add_argument('var1', help='first environment variable name')
    parser.add_argument('var2', help='second environment variable name')
    args = parser.parse_args()

    var1 = os.getenv(args.var1, None)
    var2 = os.getenv(args.var2, None)

    var1 = '' if var1 == 'false' else var1
    var2 = '' if var2 == 'false' else var2
    if var1 and var2:
        sys.exit(1)


if __name__ == '__main__':
    main()
