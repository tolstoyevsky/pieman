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

import setuptools.command.sdist
from setuptools import setup

try:
    import pypandoc
    LONG_DESCRIPTION = pypandoc.convert('README.md', 'rst')
except (ImportError, OSError):
    # OSError is raised when pandoc is not installed.
    LONG_DESCRIPTION = ('')

DATA_FILES = [('', ['requirements.txt'])]

PACKAGE_NAME = 'pieman_devices'


with open('requirements.txt') as outfile:
    REQUIREMENTS_LIST = outfile.read().splitlines()


class SdistPyCommand(setuptools.command.sdist.sdist):
    """Custom sdist command. """

    def __init__(self, dist):
        self._base_dir = os.path.dirname(os.path.abspath(__file__))
        self._pieman_devices_path = os.path.join(self._base_dir, PACKAGE_NAME)
        self._init_path = os.path.join(self._pieman_devices_path, '__init__.py')

        super().__init__(dist)

    @staticmethod
    def _copy(src, dst):
        """Copies the specified files handling FileNotFoundError and IsADirectoryError. """

        try:
            shutil.copy(src, dst)
        except FileNotFoundError:
            SdistPyCommand._fail(f'{src} does not exist')
        except IsADirectoryError:
            SdistPyCommand._fail(f'{src} cannot be a directory')

    @staticmethod
    def _expand_data_files(item):
        """Shortcut for adding the YML files to the pieman_devices package. """

        DATA_FILES.append((os.path.dirname(item), [item]))

    @staticmethod
    def _fail(message):
        """Prints the specified message to stderr and exits. """

        sys.stderr.write(f'Error: {message}\n')
        sys.exit(1)

    def _get_abs_path(self, rel_path):
        """Returns the full path which is the result of concatenation of self._base_dir and
        the specified relative path.
        """

        return os.path.join(self._base_dir, rel_path)

    @staticmethod
    def _mkdir(dir_name):
        """Creates a directory with the specified name with no error if existing. """

        try:
            Path(dir_name).mkdir()
        except FileExistsError:
            pass

    @staticmethod
    def _touch(file_name):
        """Creates an empty file with the specified name with no error if existing. """

        try:
            Path(file_name).touch()
        except FileExistsError:
            pass

    def run(self):
        SdistPyCommand._mkdir(self._pieman_devices_path)

        SdistPyCommand._copy(self._get_abs_path(f'{self._base_dir}/__init__.py'), self._init_path)

        for dev_name in os.listdir(self._base_dir):
            path_to_dev = self._get_abs_path(dev_name)
            if not Path(path_to_dev).is_dir():
                continue  # skip setup.py and other regular files

            if dev_name in ['build', 'dist', f'{PACKAGE_NAME}.egg-info', PACKAGE_NAME]:
                # skip the dirs produced as a result of 'setup.py sdist' or 'setup.py build'
                continue

            SdistPyCommand._mkdir(self._get_abs_path(f'{PACKAGE_NAME}/{dev_name}'))

            SdistPyCommand._copy(
                self._get_abs_path(f'{dev_name}/meta.yml'),
                self._get_abs_path(f'{PACKAGE_NAME}/{dev_name}/meta.yml'))

            SdistPyCommand._expand_data_files(f'{PACKAGE_NAME}/{dev_name}/meta.yml')

            for os_name in os.listdir(path_to_dev):
                path_to_os = self._get_abs_path(f'{dev_name}/{os_name}')

                if not Path(path_to_os).is_file():
                    SdistPyCommand._mkdir(
                        self._get_abs_path(f'{PACKAGE_NAME}/{dev_name}/{os_name}'))

                    dst_meta = self._get_abs_path(f'{PACKAGE_NAME}/{dev_name}/{os_name}/meta.yml')
                    if Path(path_to_os).is_symlink():
                        src_meta = self._get_abs_path(f'{dev_name}/meta_{os_name}.yml')
                        if not Path(src_meta).exists():
                            src_meta = self._get_abs_path(f'{dev_name}/{os_name}/meta.yml')

                        SdistPyCommand._copy(src_meta, dst_meta)
                    elif Path(path_to_os).is_dir():
                        src_meta = self._get_abs_path(f'{dev_name}/{os_name}/meta.yml')
                        SdistPyCommand._copy(src_meta, dst_meta)

                    SdistPyCommand._expand_data_files(
                        f'{PACKAGE_NAME}/{dev_name}/{os_name}/meta.yml')
                elif os_name.startswith('meta_'):
                    dst_meta = self._get_abs_path(f'{PACKAGE_NAME}/{dev_name}/{os_name}')
                    SdistPyCommand._copy(path_to_os, dst_meta)
                else:
                    continue  # skip regular files on the second level too

        setuptools.command.sdist.sdist.run(self)


def main():
    """The main entry point. """

    setup(name=PACKAGE_NAME,
          version='0.4',
          description='Pieman devices package',
          long_description=LONG_DESCRIPTION,
          url='https://github.com/tolstoyevsky/pieman/tree/master/devices',
          author='Evgeny Golyshev',
          maintainer='Evgeny Golyshev',
          maintainer_email='eugulixes@gmail.com',
          license='https://gnu.org/licenses/gpl-3.0.txt',
          packages=[PACKAGE_NAME],
          include_package_data=True,
          data_files=DATA_FILES,
          install_requires=REQUIREMENTS_LIST,
          cmdclass={'sdist': SdistPyCommand})


if __name__ == '__main__':
    main()
