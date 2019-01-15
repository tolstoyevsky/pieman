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

"""Utility intended to check if the Redis server is available.
It returns a zero exit status if everything is ok and non-zero exit status if
there is a problem to connect to the specified Redis server.
"""

import sys
from argparse import ArgumentParser

from redis.exceptions import RedisError

from pieman import util


def main():
    """The main entry point. """

    parser = ArgumentParser()
    parser.add_argument('-H', '--redis-host', default='127.0.0.1',
                        help='Redis server host', metavar='REDIS_HOST')
    parser.add_argument('-P', '--redis-port', default='6379',
                        help='server pid file name', metavar='REDIS_PORT',
                        type=int)

    args = parser.parse_args()

    try:
        util.connect_to_redis(args.redis_host, args.redis_port)
    except RedisError:
        sys.exit(1)


if __name__ == '__main__':
    main()
