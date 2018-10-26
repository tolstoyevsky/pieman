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

import os
import sys
import time
from argparse import ArgumentParser
from html.parser import HTMLParser
from urllib.error import URLError, HTTPError
from urllib.parse import urljoin
from urllib.request import urlopen


ARCH = 'armhf'

ALPINE_VERSION = '3.7'

MIRROR = 'http://dl-cdn.alpinelinux.org'

NAP = 1

RETRIES_NUMBER = 5


class CustomHTMLParser(HTMLParser):
    def __init__(self, content):
        HTMLParser.__init__(self, convert_charrefs=True)

        self._apk_tools_version = None
        self._content = content

    def get_apk_tools_version(self):
        self.feed(self._content)
        return self._apk_tools_version

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for name, value in attrs:
                package_name = 'apk-tools-static'
                if name == 'href' and value.startswith(package_name):
                    prefix = len(package_name) + 1
                    suffix = len('.apk')
                    self._apk_tools_version = value[prefix:-suffix]
                    break


def main():
    parser = ArgumentParser()
    parser.add_argument('--alpine-version', default=ALPINE_VERSION,
                      help='alpine version', metavar='ALPINE_VERSION')
    parser.add_argument('--arch', default=ARCH,
                      help='target architecture', metavar='ARCH')
    parser.add_argument('--mirror', default=MIRROR,
                      help='mirror', metavar='MIRROR')
    args = parser.parse_args()

    address = urljoin(args.mirror,
                      os.path.join('alpine', 'v' + args.alpine_version,
                                   'main', args.arch))

    content = b''
    for attempt in range(1, RETRIES_NUMBER + 1):
        try:
            content = urlopen(address).read()
            break
        except HTTPError as e:
            sys.stderr.write('{}: request failed (error code {})\n'.
                             format(sys.argv[0], e.code))
        except URLError as e:
            sys.stderr.write('{}: {}\n'.format(sys.argv[0], e.reason))

        if attempt != RETRIES_NUMBER:
            sys.stderr.write('Retrying in {} seconds...\n'.format(NAP))
            time.sleep(NAP)

    if content == b'' and attempt == RETRIES_NUMBER:
        sys.stderr.write('Could not request {} after {} attempts\n'.
                         format(address, RETRIES_NUMBER))
        sys.exit(1)

    parser = CustomHTMLParser(content.decode('utf8'))
    apk_tools_version = parser.get_apk_tools_version()
    if not apk_tools_version:
        sys.stderr.write('Could not get apk tools version\n')
        sys.exit(1)

    print(apk_tools_version)


if __name__ == '__main__':
    main()
