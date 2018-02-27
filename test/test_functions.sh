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
    BUILD_DIR="build"

    IMAGE="${BUILD_DIR}/mock_image.img"

    KEYRING="mock_keyring.gpg"

    MOUNT_POINT=${BUILD_DIR}/mount_point

    PIECES=(raspbian stretch armhf)

    PM_OPTIONS=""

    PROJECT_NAME="mock_project"

    PYTHON="/usr/bin/python3"

    R=${BUILD_DIR}/${PROJECT_NAME}/chroot

    SOURCE_DIR="devices/rpi-3-b/raspbian-stretch-armhf"

    USR_BIN="${R}/usr/bin"

    YML_FILE="${SOURCE_DIR}/pieman.yml"

    . ../functions.sh
}

tearDown() {
    rm -rf debootstrap
}

#
# Let the test begin
#

test_adding_package_to_includes() {
    add_package_to_includes parted
    add_package_to_includes ifupdown

    assertEquals ",parted,ifupdown" ${INCLUDES}
}

test_adding_package_pm_options() {
    add_option_to_pm_options --allow-unauthenticated
    add_option_to_pm_options --assume-yes

    assertEquals " --allow-unauthenticated --assume-yes" "${PM_OPTIONS}"
}

test_checking_mutually_exclusive_params() {
    PARAM1="true"

    local result=$((check_mutually_exclusive_params PARAM1 PARAM2 PARAM3) 2>&1)

    assertNull "${result}"

    PARAM2="true"
    PARAM3="true"

    local result=$((check_mutually_exclusive_params PARAM1 PARAM2 PARAM3) 2>&1)

    assertEquals \
        "${text_in_red_color}Fatal${reset}: PARAM1 and PARAM2 conflict with each other." \
        "${result}"
}

test_checking_if_variable_is_set() {
    assertFalse "check_if_variable_is_set NON_EXISTING_VAR"

    assertTrue "check_if_variable_is_set R"
}

test_choosing_debootstrap() {
    local result=$((PATH="/bin:/usr/bin"; choose_debootstrap) 2>&1)

    assertNotNull "$(echo ${result} | grep "there is no debootstrap")"

    mkdir -p debootstrap/debian
    touch debootstrap/debootstrap

    result=$((PATH="/bin:/usr/bin"; choose_debootstrap) 2>&1)

    # There must be an error because there is no changelog
    assertNotNull "$(echo ${result} | grep "Could not get its version")"

    echo "debootstrap (1.0.90) unstable; " \
         "urgency=medium" > debootstrap/debian/changelog

    result=$((PATH="/bin:/usr/bin"; choose_debootstrap) 2>&1)

    # There must be an error because the version of debootstrap is less than
    # required
    assertNotNull \
        "$(echo ${result} | grep "${DEBOOTSTRAP_VER} or higher is required.")"

    echo "debootstrap (1.0.91) unstable; " \
         "urgency=medium" > debootstrap/debian/changelog

    result=$((PATH="/bin:/usr/bin"; choose_debootstrap) 2>&1)

    # Everything must me fine
    assertNotNull "$(echo ${result} | grep "using ${DEBOOTSTRAP_EXEC}")"
}

test_choosing_user_mode_emulation_binary() {
    PIECES=(raspbian stretch armhf)

    choose_user_mode_emulation_binary

    assertEquals "/usr/bin/qemu-arm-static" ${EMULATOR}

    PIECES=(raspbian stretch arm64)

    choose_user_mode_emulation_binary

    assertEquals "/usr/bin/qemu-aarch64-static" ${EMULATOR}

    PIECES=(raspbian stretch mock)

    local result=$((choose_user_mode_emulation_binary) 2>&1)

    assertEquals \
        "${text_in_red_color}Fatal${reset}: Unknown architecture mock." \
        "${result}"
}

. $(which shunit2)

