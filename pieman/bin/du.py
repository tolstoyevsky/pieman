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

import math
import os
import sys
from argparse import ArgumentParser


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
    parser = ArgumentParser()
    parser.add_argument("-b", "--block-size", default=4096, type=int,
                      help="block size", metavar="SIZE")
    parser.add_argument("-m", "--size-in-megabytes", action="store_true",
                      help="return total size in megabytes", dest="megabytes")
    parser.add_argument('directory')
    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        sys.stderr.write('The {} directory does not exist\n'.format(args.directory))
        sys.exit(1)

    total_size, items_number = get_tree_size(args.directory, args.block_size)

    if args.megabytes:
        total_size = math.ceil(total_size / 1024 / 1024)

    print('Items number: {}'.format(items_number))
    print('Total size: {}'.format(total_size))


if __name__ == '__main__':
    main()
