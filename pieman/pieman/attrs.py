# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
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

"""Module intended to simplify working with pieman.yml files. """

import yaml


TYPES_SCHEME = {
    'repos': (list, ),
    'base': (list, str),
    'includes': (list, str),
    'boot': (list, str),
    'params': (list, ),
    'kernel': {
        'package': (str, ),
        'rebuild': (bool, ),
        'patches': (str, ),
    },
}


class AttributeDoesNotExist(Exception):
    """Exception raised when attempting to get an attribute which does not
    exist. """
    def __init__(self, par_name, cur_name):
        message = ('{} does not have attribute {}'.format(par_name, cur_name))
        Exception.__init__(self, message)


class RootDoesNotExist(Exception):
    """Exception raised when attempting to get the root which does not
    exist. """


class UnknownAttribute(Exception):
    """Exception raised when attempting to get an attribute which may exist
    but is not mentioned in the specification. """


class UnprintableType(Exception):
    """Exception raised when attempting to print an attribute the type of which
    is neither str nor list. """


class Attribute:  # pylint: disable=too-few-public-methods
    """Class representing a single attribute. """

    def __init__(self, attribute, attribute_type):
        self._attribute, self._attribute_type = attribute, attribute_type

    def echo(self):
        """Writes the value of the attribute to stdout or raises
        `UnprintableType` if the attribute type is neither str nor list.
        """
        if list in self._attribute_type or str in self._attribute_type:
            if isinstance(self._attribute, str):
                self._attribute = [self._attribute]

            for line in self._attribute:
                print(line)
        else:
            raise UnprintableType


class AttributesList:  # pylint: disable=too-few-public-methods
    """Class implementing the interface for working with pieman.yml files. """

    def __init__(self, attributes_file):
        with open(attributes_file, 'r') as infile:
            self._attributes = yaml.load(infile)

    def get_attribute(self, attributes_chain):
        """Gets the value of the attribute. To get the value the full path to
        the attribute must be specified starting with the root.
        """

        if attributes_chain:
            par_name = attributes_chain[0]
            try:
                cur_attribute = self._attributes[par_name]
            except KeyError:
                raise RootDoesNotExist

            cur_type = TYPES_SCHEME

            for attribute_name in attributes_chain[1:]:
                try:
                    cur_attribute = cur_attribute[attribute_name]
                except KeyError:
                    raise AttributeDoesNotExist(par_name, attribute_name)

                try:
                    cur_type = cur_type[attribute_name]
                except KeyError:
                    raise UnknownAttribute

                par_name = attribute_name

            if isinstance(cur_type, dict):
                cur_type = (dict, )

            return Attribute(cur_attribute, cur_type)

        return None
