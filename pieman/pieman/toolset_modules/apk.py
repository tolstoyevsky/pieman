# Copyright (C) 2018-2020 Evgeny Golyshev <eugulixes@gmail.com>
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

import os.path
import sys
import time
from html.parser import HTMLParser
from urllib.error import URLError, HTTPError
from urllib.parse import urljoin
from urllib.request import urlopen

from pieman import util


ALPINE_VERSION = '3.12'

FLAVOURS_ENABLED = True

MIRROR = 'http://dl-cdn.alpinelinux.org'

REQUIRED_FIELDS = ('arch', 'version', 'dst', )

RETRIES_NUMBER = 5


class CustomHTMLParser(HTMLParser):  # pylint: disable=abstract-method
    """Simplified HTML parser to find the apk-tools-static version on the
    specified page.
    """

    def __init__(self, content):
        HTMLParser.__init__(self, convert_charrefs=True)

        self._apk_tools_version = None
        self._content = content

    def get_apk_tools_version(self):
        """Returns the apk-tools-static version. """
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


def run(**kwargs):
    pass
    # arch = kwargs['arch']
    # version = kwargs['version']
    # dst = os.path.join(os.environ['TOOLSET_FULL_PATH'], kwargs['dst'])
    #
    # util.mkdir(os.path.dirname(dst))
    #
    # address = urljoin(MIRROR, os.path.join('alpine', 'v' + version, 'main', arch))
    #
    # content = b''
    # for attempt in range(1, RETRIES_NUMBER + 1):
    #     try:
    #         content = urlopen(address).read()
    #         break
    #     except HTTPError as exc:
    #         util.fatal('{}: request failed '
    #                    '(error code {})'.format(sys.argv[0], exc.code))
    #     except URLError as exc:
    #         util.fatal('{}: {}'.format(sys.argv[0], exc.reason))
    #
    #     if attempt != RETRIES_NUMBER:
    #         util.info('{}: retrying in 1 second...'.format(sys.argv[0]))
    #         time.sleep(1)
    #
    # if content == b'' and attempt == RETRIES_NUMBER:
    #     util.fatal('{}: could not request {} after {} '
    #                'attempts'.format(sys.argv[0], address, RETRIES_NUMBER))
    #     sys.exit(1)
    #
    # parser = CustomHTMLParser(content.decode('utf8'))
    # apk_tools_version = parser.get_apk_tools_version()
    # if not apk_tools_version:
    #     util.fatal('{}: could not get apk tools version'.format(sys.argv[0]))
    #     sys.exit(1)
    #
    # download_link = urljoin(address + '/', 'apk-tools-static-{}.apk'.format(apk_tools_version))
    # util.info('Downloading {}'.format(download_link))
    # util.download(download_link, dst)
