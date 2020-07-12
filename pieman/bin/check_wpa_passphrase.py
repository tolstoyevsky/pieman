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

"""Utility intended for checking if the specified WPA passphrase is valid. The
following two checks were borrowed from wpa_supplicant/wpa_passphrase.c.
The utility exits with:
* 0 when everything is fine;
* 1 when the length of the specified passphrase is not between 8 and 63
    characters;
* 2 when the specified passphrase contains special characters.
"""

import argparse
import sys


SPECIAL_CHARACTERS = [chr(n) for n in range(32)] + ['\x7f']


def main():
    """The main entry point. """

    parser = argparse.ArgumentParser()
    parser.add_argument('passphrase', help='WPA passphrase which is going to '
                                           'be passed to wpa_passphrase')
    args = parser.parse_args()

    passphrase_len = len(args.passphrase)
    if passphrase_len < 8 or passphrase_len > 63:
        sys.exit(1)

    for char in args.passphrase:
        if char in SPECIAL_CHARACTERS:
            sys.exit(2)


if __name__ == '__main__':
    main()
