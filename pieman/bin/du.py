#!/usr/bin/python3
# Copyright (C) 2018 Evgeny Golyshev <eugulixes@gmail.com>
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

# The main motivation to create a substitution for du is that it can sometimes
# provide inaccurate result. For example, directory size may vary depending on
# when du is called -- before or after transferring the directory to an image.

import os
import sys
from optparse import OptionParser


def get_tree_size(path, block_size=4096):
    """Returns total size of files and number of files in the specified
    directory.
    """
    total_size = items_number = 0

    # os.walk skips the symbolic links that resolve to directories, not
    # counting them at all. It has a great impact on the end result, so we need
    # a different way to solve the task.
    for dir_entry in fault_tolerant_scandir(path):
        items_number += 1

        if os.path.islink(dir_entry.path):
            total_size += block_size
        elif os.path.isdir(dir_entry.path):
            ret = get_tree_size(dir_entry.path)
            total_size += ret[0] + block_size
            items_number += ret[1]
        elif os.path.isfile(dir_entry.path):
            file_size = os.path.getsize(dir_entry.path)
            if file_size > block_size:
                total_size += file_size
            else:
                total_size += block_size

    return total_size, items_number


def fault_tolerant_scandir(path):
    try:
        return os.scandir(path)
    except PermissionError:
        sys.stderr.write('Permission denied when trying to figure out '
                         'the size of {}\n'.format(path))

    return []


def main():
    parser = OptionParser(usage='usage: %prog [options] <directory>')
    parser.add_option("-b", "--block-size", default=4096, type="int",
                      help="block size", metavar="SIZE")
    (options, args) = parser.parse_args()

    if len(args) < 1:
        parser.print_help()
        sys.exit(1)

    if not os.path.isdir(args[0]):
        sys.stderr.write('The {} directory does not exist\n'.format(args[0]))
        sys.exit(1)

    total_size, items_number = get_tree_size(args[0], options.block_size)

    print('Items number: {}'.format(items_number))
    print('Total size: {}'.format(total_size))


if __name__ == '__main__':
    main()
