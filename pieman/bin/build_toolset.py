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

import os
import sys
from argparse import ArgumentParser

from yaml.scanner import ScannerError

from pieman import toolset, util


def main():
    """The main entry point. """

    parser = ArgumentParser()
    parser.add_argument('yml_file', help='path to the Toolset YAML file')
    args = parser.parse_args()

    try:
        os.environ['TOOLSET_FULL_PATH']
    except KeyError:
        util.fatal('The TOOLSET_FULL_PATH environment variable is undefined.')
        sys.exit(1)

    try:
        toolset_tree = toolset.ToolsetProcessor(args.yml_file)
    except ScannerError as exp:
        util.fatal('{}'.format(exp))
        sys.exit(1)
    except AttributeError as exp:
        util.fatal('{}'.format(exp))
        sys.exit(1)
    except ModuleNotFoundError as exp:
        util.fatal('{}'.format(exp))
        sys.exit(1)
    except toolset.MissingRequiredFields as exp:
        util.fatal('{}'.format(exp))
        sys.exit(1)

    for name, module in toolset_tree:
        for flavour in module['flavours']:
            flavour_name = next(iter(flavour))
            mod = module['imported']
            mod.run(**flavour[flavour_name])


if __name__ == '__main__':
    main()
