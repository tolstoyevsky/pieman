#!/usr/bin/python3
# Copyright (C) 2019-2021 Evgeny Golyshev <eugulixes@gmail.com>
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

"""Test module for the pieman package. """

import os
import sys
import unittest
from io import StringIO
from os.path import abspath, dirname

import yaml

from pieman import attrs, preprocessor


class AttrsTestCase(unittest.TestCase):
    """Tests related to the attrs.py module. """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        current_mod = sys.modules[__name__]
        test_path = dirname(abspath(current_mod.__file__))
        pieman_yml = '{}/{}'.format(test_path, 'pieman.yml')

        with open(pieman_yml) as infile:
            self._attrs_list = attrs.AttributesList(infile)

        self._old_stdout = sys.stdout
        self._new_stdout = StringIO()

    def setUp(self):
        sys.stdout = self._new_stdout

    def tearDown(self):
        sys.stdout = self._old_stdout

    def test_empty_attributes_chain(self):
        """Tests if the attributes chain is empty (i.e. doesn't contain any attributes). """

        self.assertIsNone(self._attrs_list.get_attribute([]))

    def test_existent_root(self):
        """Tests if it's possible to find the root in an attributes chain. """

        raspbian = self._attrs_list.get_attribute(('raspbian-buster-armhf', ))
        self.assertIsInstance(raspbian, attrs.Attribute)

    def test_nonexistent_root(self):
        """Tests raising RootDoesNotExist in case of trying to find the root
        which doesn't exist.
        """

        with self.assertRaises(attrs.RootDoesNotExist):
            self._attrs_list.get_attribute(('nonexistent_root', ))

    def test_existent_attribute(self):
        """Tests if it's possible to fetch the value of the specified attribute. """

        includes = self._attrs_list.get_attribute(
            ('raspbian-buster-armhf', 'includes')
        )
        self.assertEqual(includes.attribute, 'systemd-sysv')

    def test_nonexistent_attribute(self):
        """Tests raising AttributeDoesNotExist in case of trying to fetch the
        value of the specified attribute which doesn't exist.
        """

        with self.assertRaises(attrs.AttributeDoesNotExist):
            self._attrs_list.get_attribute(
                ('raspbian-buster-armhf', 'nonexistent_attribute')
            )

    def test_unknown_attribute(self):
        """Tests raising UnknownAttribute in case of trying to fetch the value
        of the specified attribute which is unknown.
        """

        with self.assertRaises(attrs.UnknownAttribute):
            self._attrs_list.get_attribute(
                ('raspbian-buster-armhf', 'unknown')
            )

    def test_printing_printable_attribute(self):
        """Tests if it's possible to print the value of the specified printable attribute. """

        includes = self._attrs_list.get_attribute(
            ('raspbian-buster-armhf', 'includes')
        )
        # The includes type is list or str which are printable.
        includes.echo()
        self.assertEqual(self._new_stdout.getvalue(), 'systemd-sysv\n')
        self._new_stdout.close()

    def test_printing_unprintable_attribute(self):
        """Tests if it's possible to print the value of the specified unprintable attribute. """

        kernel = self._attrs_list.get_attribute(
            ('raspbian-buster-armhf', 'kernel')
        )
        with self.assertRaises(attrs.UnprintableType):
            # The kernel type is dict, so that's why UnprintableType must be
            # raised when trying to print the value of the attribute.
            kernel.echo()


class PreporcessorTestCase(unittest.TestCase):
    """A class that implements the tests related to the preprocessor.py module. """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self._toolset_yml = os.path.dirname(os.path.abspath(__file__)) + '/toolset.yml'

        self._old_stdout = sys.stdout
        self._new_stdout = StringIO()

    def setUp(self):
        sys.stdout = self._new_stdout

    def tearDown(self):
        sys.stdout.close()
        sys.stdout = self._old_stdout

        try:
            del os.environ['TOOLSET_DIR']
        except KeyError:
            pass

    def test_wrong_root_name(self):
        """Tests if RootNameCouldNotBeFound is raised if a wrong root name was passed
        to the preprocessor.
        """

        with self.assertRaises(preprocessor.RootNameCouldNotBeFound):
            preprocessor.Preprocessor(self._toolset_yml, sys.stdout, 'toolset1')

    def test_undefined_variable(self):
        """Tests if UndefinedVariable is raised when the preprocessor meets
        an undefined variable.
        """

        with self.assertRaises(preprocessor.UndefinedVariable):
            preprocessor.Preprocessor(self._toolset_yml, sys.stdout, 'toolset')

    def test_variable_substitution(self):
        """Tests variable substitution, i.e. referencing (retrieving) variables values. """

        os.environ['TOOLSET_DIR'] = toolset_dir = 'path/to/toolset'
        preprocessor.Preprocessor(self._toolset_yml, sys.stdout, 'toolset')
        parsed = yaml.load(sys.stdout.getvalue(), Loader=yaml.FullLoader)

        arch = 'armhf'
        version = parsed['toolset']['apk'][arch]['version']
        dst = parsed['toolset']['apk'][arch]['dst']
        self.assertEqual(dst, f"{toolset_dir}/apk/{version}/apk-{arch}.static")


if __name__ == '__main__':
    unittest.main()
