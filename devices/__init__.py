# Copyright (C) 2020 Denis Gavrilyuk <karpa4o4@gmail.com>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Module containing the interface for serving the devices and operating systems supported
by Pieman to clients.
"""

import os
from pathlib import Path

import yaml

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def _get_abs_path(rel_path):
    """Returns the full path which is the result of concatenation of BASE_DIR and the specified
    relative path.
    """

    return os.path.join(BASE_DIR, rel_path)


def get_devices():
    """Returns the list of the devices and operating systems supported by Pieman. """

    devices = {}

    for dev_name in os.listdir(BASE_DIR):
        path_to_dev = _get_abs_path(dev_name)
        if not Path(path_to_dev).is_dir():
            continue  # skip __init__.py and other regular files
        if dev_name in ['__pycache__']:
            continue

        with open(f'{path_to_dev}/meta.yml') as outfile:
            dev_meta = yaml.safe_load(outfile)['meta']

        distros = {}

        for distro_name in os.listdir(path_to_dev):
            path_to_distro = _get_abs_path(f'{path_to_dev}/{distro_name}')
            if not Path(path_to_distro).is_dir():
                continue  # skip meta.yml of device and other file

            path_to_distro_meta = f'{path_to_dev}/{distro_name}/meta.yml'
            path_to_overridden_distro = _get_abs_path(f'{path_to_dev}/meta_{distro_name}.yml')
            if Path(path_to_overridden_distro).exists():
                path_to_distro_meta = path_to_overridden_distro

            with open(path_to_distro_meta) as outfile:
                distro_meta = yaml.safe_load(outfile)['meta']
            distros[distro_name] = distro_meta

        devices[dev_name] = {**dev_meta, 'distros': distros}

    return devices
