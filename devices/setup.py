# Copyright (C) 2020 Evgeny Golyshev <eugulixes@gmail.com>
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

"""Script for building the pieman_devices package. """

import os
import shutil
import sys
from pathlib import Path

from setuptools import setup

try:
    import pypandoc
    LONG_DESCRIPTION = pypandoc.convert('README.md', 'rst')
except (ImportError, OSError):
    # OSError is raised when pandoc is not installed.
    LONG_DESCRIPTION = ('')

DATA_FILES = []

PACKAGE_NAME = 'pieman_devices'

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

PIEMAN_DEVICES_PATH = os.path.join(BASE_DIR, PACKAGE_NAME)

INIT_PATH = os.path.join(PIEMAN_DEVICES_PATH, '__init__.py')


def copy(src, dst):
    """Copies the specified files handling FileNotFoundError and IsADirectoryError. """

    try:
        shutil.copy(src, dst)
    except FileNotFoundError:
        fail(f'{src} does not exist')
    except IsADirectoryError:
        fail(f'{src} cannot be a directory')


def expand_data_files(item):
    """Shortcut for adding the YML files to the pieman_devices package. """

    DATA_FILES.append((os.path.dirname(item), [item]))


def fail(message):
    """Prints the specified message to stderr and exits. """

    sys.stderr.write(f'Error: {message}\n')
    sys.exit(1)


def get_abs_path(rel_path):
    """Returns the full path which is the result of concatenation of BASE_DIR and the specified
    relative path.
    """

    return os.path.join(BASE_DIR, rel_path)


def mkdir(dir_name):
    """Creates a directory with the specified name with no error if existing. """

    try:
        Path(dir_name).mkdir()
    except FileExistsError:
        pass


def touch(file_name):
    """Creates an empty file with the specified name with no error if existing. """

    try:
        Path(file_name).touch()
    except FileExistsError:
        pass


def main():
    """The main entry point. """

    mkdir(PIEMAN_DEVICES_PATH)

    copy(get_abs_path(f'{BASE_DIR}/__init__.py'), INIT_PATH)

    for dev_name in os.listdir(BASE_DIR):
        path_to_dev = get_abs_path(dev_name)
        if not Path(path_to_dev).is_dir():
            continue  # skip setup.py and other regular files

        if dev_name in ['build', 'dist', f'{PACKAGE_NAME}.egg-info', PACKAGE_NAME]:
            continue  # skip the dirs produced as a result of 'setup.py sdist' or 'setup.py build'

        mkdir(get_abs_path(f'{PACKAGE_NAME}/{dev_name}'))

        copy(get_abs_path(f'{dev_name}/meta.yml'),
             get_abs_path(f'{PACKAGE_NAME}/{dev_name}/meta.yml'))

        expand_data_files(f'{PACKAGE_NAME}/{dev_name}/meta.yml')

        for os_name in os.listdir(path_to_dev):
            path_to_os = get_abs_path(f'{dev_name}/{os_name}')

            if not Path(path_to_os).is_file():
                mkdir(get_abs_path(f'{PACKAGE_NAME}/{dev_name}/{os_name}'))

                dst_meta = get_abs_path(f'{PACKAGE_NAME}/{dev_name}/{os_name}/meta.yml')
                if Path(path_to_os).is_symlink():
                    src_meta = get_abs_path(f'{dev_name}/meta_{os_name}.yml')
                    if not Path(src_meta).exists():
                        src_meta = get_abs_path(f'{dev_name}/{os_name}/meta.yml')

                    copy(src_meta, dst_meta)
                elif Path(path_to_os).is_dir():
                    src_meta = get_abs_path(f'{dev_name}/{os_name}/meta.yml')
                    copy(src_meta, dst_meta)

                expand_data_files(f'{PACKAGE_NAME}/{dev_name}/{os_name}/meta.yml')
            elif os_name.startswith('meta_'):
                dst_meta = get_abs_path(f'{PACKAGE_NAME}/{dev_name}/{os_name}')
                copy(path_to_os, dst_meta)
            else:
                continue  # skip regular files on the second level too

    setup(name=PACKAGE_NAME,
          version='0.1',
          description='Pieman devices package',
          long_description=LONG_DESCRIPTION,
          url='https://github.com/tolstoyevsky/pieman',
          author='Evgeny Golyshev',
          maintainer='Evgeny Golyshev',
          maintainer_email='eugulixes@gmail.com',
          license='https://gnu.org/licenses/gpl-3.0.txt',
          packages=[PACKAGE_NAME],
          include_package_data=True,
          data_files=DATA_FILES)


if __name__ == '__main__':
    main()
