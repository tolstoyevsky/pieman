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
    pass


class UnknownAttribute(Exception):
    """Exception raised when attempting to get an attribute which may exist
    but is not mentioned in the specification. """
    pass


class UnprintableType(Exception):
    """Exception raised when attempting to print an attribute the type of which
    is neither str nor list. """
    pass


class Attribute:
    def __init__(self, attribute, attribute_type):
        self._attribute, self._attribute_type = attribute, attribute_type

    def echo(self):
        if list in self._attribute_type or str in self._attribute_type:
            if type(self._attribute) == str:
                self._attribute = [self._attribute]

            for line in self._attribute:
                print(line)
        else:
            raise UnprintableType


class AttributesList:
    def __init__(self, attributes_file):
        with open(attributes_file, 'r') as f:
            self._attributes = yaml.load(f)

    def get_attribute(self, attributes_chain):
        if len(attributes_chain) > 0:
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

            if type(cur_type) == dict:
                cur_type = dict,

            return Attribute(cur_attribute, cur_type)
