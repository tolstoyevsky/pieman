#!/usr/bin/python3
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

"""BSC client. BSC stands for Build Status Codes. """

import os
import socket
import sys
from argparse import ArgumentParser

import bscd


def main():
    """The main entry point. """

    parser = ArgumentParser()
    parser.add_argument('-a', '--unix-socket-name',
                        default='/var/run/{}.sock'.format(bscd.DAEMON_NAME),
                        help='Unix domain socket file name',
                        metavar='UNIX_SOCKET_NAME')
    parser.add_argument('-H', '--redis-host', default='127.0.0.1',
                        help='Redis server host', metavar='REDIS_HOST')
    parser.add_argument('-P', '--redis-port', default='6379',
                        help='server pid file name', metavar='REDIS_PORT',
                        type=int)
    parser.add_argument('request', metavar='REQUEST',
                        help='request to be sent to bsc server')

    args = parser.parse_args()

    if not os.path.exists(args.unix_socket_name):
        sys.stderr.write('{} does not exist\n'.format(args.unix_socket_name))
        sys.exit(1)

    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    try:
        client.connect(args.unix_socket_name)
    except ConnectionRefusedError:
        sys.stderr.write('Connection refused\n')
        sys.exit(1)

    client.send(args.request.encode('utf-8'))
    client.close()


if __name__ == '__main__':
    main()
