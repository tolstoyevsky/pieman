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

"""Utility intended for rendering Jinja2 templates.
The utility exits with:
* 0 when everything is fine;
* 1 when the specified template does not exist;
* 2 when the directory of the specified result path does not exist.
"""

import argparse
import os
import sys

from jinja2 import Environment, FileSystemLoader


def getenv(value, key):
    """Acts like any Jinja2 filter and gets the value of the specified
    environment variable.
    Note that the filter returns the native Python boolean if the environment
    variable contains 'false' . It's necessary for using the values in
    conditions.
    """

    val = os.getenv(key, value)
    return False if val == 'false' else val


def main():
    """The main entry point. """

    parser = argparse.ArgumentParser()
    parser.add_argument('template_path', help='path to the template to be '
                                              'rendered')
    parser.add_argument('result_path', help='path to the result of rendering')
    args = parser.parse_args()

    template_dir = os.path.dirname(args.template_path)
    template_name = os.path.basename(args.template_path)
    result_dir = os.path.dirname(args.result_path)

    if not os.path.isfile(args.template_path):
        sys.exit(1)

    if not os.path.isdir(result_dir):
        sys.exit(2)

    env = Environment(loader=FileSystemLoader(template_dir))
    env.filters['getenv'] = getenv

    template = env.get_template(template_name)
    output = template.render()

    with open(args.result_path, 'w') as outfile:
        outfile.write(output)


if __name__ == '__main__':
    main()
