#!/usr/bin/env python3
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

"""Utility intended for checking if the dependency environment variables,
passed as the 2nd, 3rd, etc arguments to the utility, are set to true (if bool)
or simply specified (in other cases) when the dependent environment variable,
passed as the first argument to the utility, is set to true (if bool) or simply
specified (in other cases).
"""

import argparse
import os
import sys


def main():
    """The main entry point. """

    parser = argparse.ArgumentParser()
    parser.add_argument('var', help='name of dependent environment variable')
    parser.add_argument('dependency_var', help='name of environment variable '
                                               'var1 depends on')
    args = parser.parse_args()

    var = os.getenv(args.var, None)
    dependency_var = os.getenv(args.dependency_var, None)

    var = '' if var == 'false' else var
    dependency_var = '' if dependency_var == 'false' else dependency_var
    if not var:
        sys.exit(0)

    if not dependency_var:
        sys.exit(1)


if __name__ == '__main__':
    main()
