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

import os
import re
import yaml
from importlib import import_module


class RootNameIsNotValid(Exception):
    pass


class MissingRequiredFields(Exception):
    def __init__(self, module_name, flavour_name, missing_fields):
        super().__init__('The {} flavour of the {} module misses some of the required fields: '
                         '{}'.format(flavour_name, module_name, ', '.join(missing_fields)))


class UndefinedVariable(Exception):
    def __init__(self, var_name):
        super().__init__("The variable '{}' is undefined".format(var_name))


class PreProcessor:
    def __init__(self, file_name, new_file_name, root_name='toolset'):
        with open(file_name, 'r') as infile:
            self._toolset = yaml.load(infile, Loader=yaml.FullLoader)

        self._root_name = root_name
        self._tree = None

        self._get_tree()

        self._var_re = re.compile(r'\${([\w\d]+)}')

        self._go_through_all_yml(self._tree, self._toolset)

        new_tree = {self._root_name: self._tree}
        with open(new_file_name, 'w') as outfile:
            yaml.dump(new_tree, outfile, default_flow_style=False)

    #
    # Private methods
    #

    def _get_tree(self):
        try:
            self._tree = self._toolset[self._root_name]
        except KeyError:
            raise RootNameIsNotValid

    def _go_through_all_yml(self, parent_node, node, table_names=None, parent_node_name=''):
        table_names = table_names if table_names else {}

        if isinstance(node, dict):
            for key, val in node.items():
                table_names['parent_node_name'] = parent_node_name
                if not isinstance(val, (dict, list, )):
                    table_names[key] = val

                self._go_through_all_yml(node, val, table_names, key)
        elif isinstance(node, list):
            for i in node:
                self._go_through_all_yml(node, i)
        else:
            node_value = parent_node[parent_node_name]
            while True:
                if not isinstance(node_value, str):
                    break

                match = self._var_re.search(node_value)
                if match is None:
                    break

                var_name = match[1]
                try:
                    value = table_names[var_name]
                except KeyError:
                    try:
                        value = os.environ[var_name]
                    except KeyError:
                        raise UndefinedVariable(var_name)

                node_value = node_value.replace(match[0], value)

            parent_node[parent_node_name] = node_value


class ToolsetProcessor:
    def __init__(self, file_name):
        with open(file_name, 'r') as infile:
            self._toolset = yaml.load(infile, Loader=yaml.FullLoader)

        self._modules = {}

        self._get_root()

        self._process_modules()

        self._validate_modules()

    #
    # Private methods
    #

    def _get_root(self):
        try:
            self._root = self._toolset['toolset']
        except KeyError:
            raise RootNameIsNotValid

    def _process_modules(self):
        """Raises ModuleNotFoundError if one of the specified modules doesn't exist. """

        for module in self._root:
            module_name = next(iter(module))
            mod = self._modules[module_name] = {}
            mod['imported'] = imported = import_module('.' + module_name,
                                                       package='pieman.toolset_modules')

            if imported.FLAVOURS_ENABLED:
                mod['flavours'] = module[module_name]
            else:
                mod['flavours'] = [{'default': module[module_name]}]

    def _validate_modules(self):
        """Raises AttributeError if the REQUIRED_FIELDS attribute is absent in one of the
        modules.
        """

        for module_name, module in self._modules.items():
            for flavour in module['flavours']:
                flavour_name = next(iter(flavour))
                got_fields = set(flavour[flavour_name].keys())
                required_fields = set(module['imported'].REQUIRED_FIELDS)
                missing_fields = required_fields - got_fields
                if missing_fields:
                    raise MissingRequiredFields(module_name, flavour_name, missing_fields)

    def __iter__(self):
        return iter(self._modules.items())
