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

"""Miscellaneous utility functions. """

import logging

import redis

LOGGING_FORMATTER = '%(asctime)s %(levelname)-5.5s %(message)s'


def connect_to_redis(host, port):
    """Connects to the specified Redis server. The function raises on of the
    exceptions derived from redis.exceptions.RedisError in case of a problem.
    """
    conn = redis.StrictRedis(host=host, port=port)
    conn.ping()

    return conn


def init_logger(logger, log_level, log_file_prefix='',
                logging_formatter=LOGGING_FORMATTER):
    """Initializes the logger. """

    formatter = logging.Formatter(logging_formatter)
    logger.setLevel(log_level)

    streaming_handler = logging.StreamHandler()
    streaming_handler.setLevel(log_level)
    streaming_handler.setFormatter(formatter)
    logger.addHandler(streaming_handler)

    if log_file_prefix:
        file_handler = logging.FileHandler(log_file_prefix)
        file_handler.setFormatter(formatter)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
