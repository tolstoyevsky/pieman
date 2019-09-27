#!/usr/bin/python3
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

import sys
from argparse import ArgumentParser

from yaml.scanner import ScannerError

from pieman import toolset


def main():
    """The main entry point. """

    parser = ArgumentParser()
    parser.add_argument('infile', help='path to the file to be processed')
    parser.add_argument('outfile', help='path to the result file')
    args = parser.parse_args()

    try:
        toolset.PreProcessor(args.infile, args.outfile)
    except ScannerError as exp:
        sys.stderr.write('{}\n'.format(exp))
        sys.exit(1)
    except toolset.UndefinedVariable as exp:
        sys.stderr.write('{}\n'.format(exp))
        sys.exit(1)


if __name__ == '__main__':
    main()
