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

"""Test module for the pieman package. """

import sys
import unittest
from io import StringIO
from os.path import abspath, dirname

from pieman import attrs


class AttrsTestCase(unittest.TestCase):
    """Tests related to the attrs.py module. """

    def __init__(self, *args, **kwargs):
        super(AttrsTestCase, self).__init__(*args, **kwargs)

        current_mod = sys.modules[__name__]
        test_path = dirname(abspath(current_mod.__file__))
        pieman_yml = '{}/{}'.format(test_path, 'pieman.yml')

        self._attrs_list = attrs.AttributesList(pieman_yml)
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


if __name__ == '__main__':
    unittest.main()
