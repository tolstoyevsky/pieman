# Copyright (C) 2021 Evgeny Golyshev <eugulixes@gmail.com>
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

"""A module that provides an implementation of the preprocessor of YAML files. The main function
of the preprocessor is variable substitution, i.e. referencing (retrieving) variables values. The
preprocessor supports the ${VAR} syntax to reference variables values. There are three types of
variables:
* environment variables (for example, ${USER} or ${HOME});
* the ${parent_node_name} builtin which contains parent nodes names, as it's seen from the name of
  the variable;
* every string type node.
"""

import os
import re
import yaml


class RootNameCouldNotBeFound(Exception):
    """Raised when the specified root name could not be found in the target YAML file. """

    def __init__(self, root_name):
        super().__init__(f"The root name '{root_name}' could not be found")


class UndefinedVariable(Exception):
    """Raised when the target YAML file references to an undefined variable. """

    def __init__(self, var_name):
        super().__init__(f"The variable '{var_name}' is undefined")


class Preprocessor:  # pylint: disable=too-few-public-methods
    """A class that provides an implementation of the preprocessor of YAML files. """

    def __init__(self, file_name, outfile, root_name):
        with open(file_name, 'r') as infile:
            self._toolset = yaml.load(infile, Loader=yaml.FullLoader)

        self._root_name = root_name
        self._tree = None

        self._get_tree()

        self._var_re = re.compile(r'\${([\w\d]+)}')

        self._go_through_all_yml(self._tree, self._toolset)

        new_tree = {self._root_name: self._tree}
        yaml.dump(new_tree, outfile, default_flow_style=False)

    #
    # Private methods
    #

    def _get_tree(self):
        try:
            self._tree = self._toolset[self._root_name]
        except KeyError as exc:
            raise RootNameCouldNotBeFound(self._root_name) from exc

    def _go_through_all_yml(self, parent_node, node, table_names=None, parent_node_name=None):
        table_names = table_names if table_names else {}

        if isinstance(node, dict):
            for key, val in node.items():
                table_names['parent_node_name'] = parent_node_name
                if not isinstance(val, (dict, list, )):
                    table_names[key] = val

                self._go_through_all_yml(node, val, table_names, key)
        elif isinstance(node, list):
            for i, val in enumerate(node):
                table_names['parent_node_name'] = parent_node_name
                self._go_through_all_yml(node, val, table_names, i)
        else:
            node_value = parent_node[parent_node_name]
            while True:  # find all variables and substitute them for their values in the loop
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
                    except KeyError as exc:
                        raise UndefinedVariable(var_name) from exc

                node_value = node_value.replace(match[0], value)

            parent_node[parent_node_name] = node_value
