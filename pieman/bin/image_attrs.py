#!/usr/bin/env python3
# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
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

from pieman import attrs


def fail(message):
    """Writes the specified message to stderr and exits with a non-zero exit
    code. """
    sys.stderr.write(message + '\n')
    exit(1)


def main():
    parser = ArgumentParser()
    parser.add_argument('-f', '--file', dest='file', default='pieman.yaml',
                      help='path to a YAML file which describes the target '
                           'image')
    parser.add_argument('root', nargs='*')
    args = parser.parse_args()

    if not os.path.isfile(args.file):
        fail('{} does not exist'.format(args.file))

    attributes_list = attrs.AttributesList(args.file)

    try:
        attr = attributes_list.get_attribute(args.root)
    except attrs.RootDoesNotExist:
        fail('There is no root named {}'.format(args.root))
    except attrs.AttributeDoesNotExist as e:
        fail(str(e))
    except attrs.UnknownAttribute:
        fail('{} attribute is unknown'.format(args.root[-1]))

    try:
        attr.echo()
    except attrs.UnprintableType:
        fail('{} attribute is not supposed to be printed'.format(args.root[-1]))


if __name__ == "__main__":
    main()
