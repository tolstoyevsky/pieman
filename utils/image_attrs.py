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
from optparse import OptionParser

from utils import attrs


def fail(message):
    """Writes the specified message to stderr and exits with a non-zero exit
    code. """
    sys.stderr.write(message + '\n')
    exit(1)


def main():
    usage = "Usage: %prog [options] root [features]"
    parser = OptionParser(usage=usage)
    parser.add_option('-f', '--file', dest='file', default='pieman.yaml',
                      help='path to a YAML file which describes the target '
                           'image')

    (options, args) = parser.parse_args()

    if len(args) < 1:
        fail('{} must take at least one argument'.format(sys.argv[0]))

    if not os.path.isfile(options.file):
        fail('{} does not exist'.format(options.file))

    attributes_list = attrs.AttributesList(options.file)

    try:
        attr = attributes_list.get_attribute(args)
    except attrs.RootDoesNotExist:
        fail('There is no root named {}'.format(args[0]))
    except attrs.AttributeDoesNotExist as e:
        fail(str(e))
    except attrs.UnknownAttribute:
        fail('{} attribute is unknown'.format(args[-1]))

    try:
        attr.echo()
    except attrs.UnprintableType:
        fail('{} attribute is not supposed to be printed'.format(args[-1]))


if __name__ == "__main__":
    main()
