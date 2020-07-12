#!/usr/bin/env python3
# Copyright (C) 2019 Denis Gavrilyuk <karpa4o4@gmail.com>
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

"""Very limited alternative of GNU Wget, but enough to be a drop-in
replacement in Pieman.
"""

import argparse
import sys

from pieman.util import download


def main():
    """The main entry point."""

    parser = argparse.ArgumentParser()
    parser.add_argument('url', help='the URL to be downloaded')
    parser.add_argument('--output-document', '-O',
                        help='writes the document to the specified file')
    parser.add_argument('-quiet', '-q', action='store_true',
                        help='makes {} mute'.format(sys.argv[0]))
    args = parser.parse_args()

    url = args.url
    output_document = args.output_document
    quiet = args.quiet

    path = output_document if output_document else url.split('/')[-1]
    download(url, path, quiet)


if __name__ == '__main__':
    main()
