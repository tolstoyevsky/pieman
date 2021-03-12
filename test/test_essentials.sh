#!/bin/bash
# Copyright (C) 2018 Evgeny Golyshev <eugulixes@gmail.com>
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

#
# Mock the variables which are required by functions.sh
#

setUp() {
    PIEMAN_DIR="${PIEMAN_DIR:=$(pwd)}"

    . "${PIEMAN_DIR}"/essentials.sh

    FATAL="${text_in_red_color}Fatal${reset}"
}

#
# Let the test begin
#

test_defining_private_variables() {
    priv="test"

    def_private_var priv "default"
    assertEquals "default" "${priv}"

    def_private_var priv2 "default"
    assertEquals "default" "${priv2}"

    def_private_var EMPTY ""
    assertNull "${EMPTY}"
}

test_defining_variables() {
    S1="test"
    def_var S1 "value by default"
    assertEquals "test" "${S1}"

    def_var S2 "value by default"
    assertEquals "value by default" "${S2}"

    def_var S3 "default"
    assertEquals "default" "${S3}"

    def_var BOOLEAN true
    assertTrue "${BOOLEAN}"

    def_var EMPTY ""
    assertNull "${EMPTY}"
}

test_defining_bool_variables() {
    local result=$((def_bool_var V1 "test") 2>&1)
    local output="+ V1=test"
    local len=$((${#output} + 1)) # plus a new line character
    assertEquals "${FATAL}: V1 must be a boolean" "${result:len}"

    result=$((def_bool_var V2 "") 2>&1)
    output="+ V2="
    len=$((${#output} + 1))
    assertEquals "${FATAL}: V2 must be a boolean" "${result:len}"

    def_bool_var V3 "true"
    assertTrue "${V3}"

    def_bool_var V4 "false"
    assertFalse "${V4}"
}

test_defining_int_variables() {
    local result=$((def_int_var N1 hello) 2>&1)
    local output="+ N1=hello"
    local len=$((${#output} + 1)) # plus a new line character
    assertEquals "${FATAL}: N1 must be an integer" "${result:len}"

    def_int_var N2 1337
    assertEquals 1337 "${N2}"
}

test_defining_protected_variables() {
    S1="test"
    def_protected_var S1 "value by default"
    assertEquals "test" "${S1}"

    def_protected_var S2 "value by default"
    assertEquals "value by default" "${S2}"

    def_protected_var S3 "default"
    assertEquals "default" "${S3}"

    def_protected_var B true
    assertTrue "${B}"

    DASH="-"
    def_protected_var DASH "value by default" << EOF
different value
EOF
    assertEquals "different value" "${DASH}"

    def_protected_var EMPTY ""
    assertNull "${EMPTY}"
}

. $(command -v shunit2)
