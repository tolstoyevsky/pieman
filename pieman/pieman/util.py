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
import os
import sys
from curses import tparm, tigetstr, setupterm
from urllib.request import urlretrieve

#import redis


setupterm()


LOGGING_FORMATTER = '%(asctime)s %(levelname)-5.5s %(message)s'

RED = tparm(tigetstr('setaf'), 1).decode('utf8')

YELLOW = tparm(tigetstr('setaf'), 3).decode('utf8')

RESET = tparm(tigetstr('sgr0')).decode('utf8')


def _reporthook(chunk_number, buffer_size, total_size):
    """It must accept three numeric parameters:
    - a chunk number;
    - the maximum size chunks are read in;
    - the total size of the download (-1 if unknown).
    """

    readsofar = chunk_number * buffer_size
    readsofar = total_size if readsofar > total_size else readsofar
    if total_size:
        percent = readsofar * 100 / total_size
        status = '\r{:>5.1f}% {:>{n}} / {}'.format(
            percent, readsofar, total_size, n=len(str(total_size)))
        sys.stderr.write(status)
    else:  # total size is unknown
        sys.stderr.write('\rread {}'.format(readsofar))


def connect_to_redis(host, port):
    """Connects to the specified Redis server. The function raises on of the
    exceptions derived from redis.exceptions.RedisError in case of a problem.
    """
    conn = redis.StrictRedis(host=host, port=port)
    conn.ping()

    return conn


def download(url, dst, quiet=False):
    """Downloads the specified document from the Web,
    (optionally) displaying a progress bar.
    """
    _, msg = urlretrieve(url, dst + '.part',
                         _reporthook if not quiet else None)

    os.rename(dst + '.part', dst)

    size = os.stat(dst).st_size
    if not quiet:
        sys.stderr.write('\n')
        if int(msg['Content-Length']) == size:
            filename = os.path.basename(dst)
            sys.stderr.write('{} was downloaded successfully\n'
                             .format(filename))


def fatal(text):
    sys.stderr.write('{}fatal{}: {}\n'.format(RED, RESET, text))


def info(text):
    sys.stderr.write('{}info{}: {}\n'.format(YELLOW, RESET, text))


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


def mkdir(dir_name):
    """Creates the specified directory, making parent directories
    as needed.
    """

    if not os.path.exists(dir_name):
        os.makedirs(dir_name)


def run_program(args):
    """Runs the executable file (which is searched for along $PATH) with argument list args. """

    pid = os.fork()
    if pid == 0:  # child
        os.execvp(args[0], args)
    else:  # parent
        _, status = os.wait()
        return status >> 8
