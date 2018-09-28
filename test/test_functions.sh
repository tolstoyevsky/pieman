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

    PIEMAN_DIR="."

    PM_OPTIONS=""

    PROJECT_NAME="mock_project"

    PYTHON="/usr/bin/python3"

    R=${BUILD_DIR}/${PROJECT_NAME}/chroot

    SOURCE_DIR="devices/rpi-3-b/raspbian-stretch-armhf"

    TOOLSET_DIR="${PIEMAN_DIR}/toolset"

    USR_BIN="${R}/usr/bin"

    YML_FILE="${SOURCE_DIR}/pieman.yml"

    . ../essentials.sh

    for script in ../helpers/*.sh; do
        . ${script}
    done
}

tearDown() {
    rm -rf "${TOOLSET_DIR}"
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

test_choosing_compressor() {
    local compressor=""

    COMPRESS_WITH_BZIP2=true
    COMPRESS_WITH_GZIP=false
    COMPRESS_WITH_XZ=false

    compressor="$(choose_compressor)"

    assertEquals "bzip2 .bz2" "${compressor}"

    COMPRESS_WITH_BZIP2=false
    COMPRESS_WITH_GZIP=true
    COMPRESS_WITH_XZ=false

    compressor="$(choose_compressor)"

    assertEquals "gzip .gz" "${compressor}"

    COMPRESS_WITH_BZIP2=false
    COMPRESS_WITH_GZIP=false
    COMPRESS_WITH_XZ=true

    compressor="$(choose_compressor)"

    assertEquals "xz .xz" "${compressor}"

    COMPRESS_WITH_BZIP2=false
    COMPRESS_WITH_GZIP=false
    COMPRESS_WITH_XZ=false

    compressor="$(choose_compressor)"

    assertNull "${compressor}"
}

test_checking_if_debootstrap_is_uptodate() {
    mkdir -p "${TOOLSET_DIR}"/debootstrap/debian
    touch "${TOOLSET_DIR}"/debootstrap/debootstrap

    result=$((is_debootstrap_uptodate) 2>&1)

    # There must be an error because there is no changelog
    assertNotNull "$(echo ${result} | grep "Could not get its version")"

    echo "debootstrap (1.0.90) unstable; " \
         "urgency=medium" > "${TOOLSET_DIR}"/debootstrap/debian/changelog

    # There must be an error because the version of debootstrap is less than
    # required
    is_debootstrap_uptodate
    assertTrue "[ $? -eq ${SHUNIT_FALSE} ]"

    echo "debootstrap (${DEBOOTSTRAP_VER}) unstable; " \
         "urgency=medium" > "${TOOLSET_DIR}"/debootstrap/debian/changelog

    # Everything must me fine
    is_debootstrap_uptodate
    assertTrue "[ $? -eq ${SHUNIT_TRUE} ]"
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

