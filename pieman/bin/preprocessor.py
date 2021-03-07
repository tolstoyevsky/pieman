#!/usr/bin/env python3
# Copyright (C) 2021 Evgeny Golyshev <eugulixes@gmail.com>
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

"""A utility that takes a YAML file and prints it to stdout, substituting variables for their
values. The preprocessor supports the ${VAR} syntax to reference variables values. There are
three types of variables:
* environment variables (for example, ${USER} or ${HOME});
* the ${parent_node_name} builtin which contains parent nodes names, as it's seen from the name of
  the variable;
* every string type node.
"""

import os
import sys
from argparse import ArgumentParser

from yaml.scanner import ScannerError

from pieman.preprocessor import (
    Preprocessor,
    RootNameCouldNotBeFound,
    UndefinedVariable,
)


def main():
    """The main entry point. """

    parser = ArgumentParser()
    parser.add_argument('infile', help='path to the YAML file to be processed')
    parser.add_argument('root_name', help='root name in the YAML file')
    args = parser.parse_args()

    if not os.path.isfile(args.infile):
        sys.stderr.write(f'{args.file} does not exist\n')
        sys.exit(1)

    try:
        Preprocessor(args.infile, sys.stdout, args.root_name)
    except (ScannerError, RootNameCouldNotBeFound, UndefinedVariable) as exp:
        sys.stderr.write(f'{exp}\n')
        sys.exit(1)


if __name__ == '__main__':
    main()
