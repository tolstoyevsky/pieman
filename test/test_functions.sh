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
    ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/.."

    BUILD_DIR="build"

    DEBOOTSTRAP_EXEC="debootstrap_mock"

    IMAGE="${BUILD_DIR}/mock_image.img"

    KEYRING="mock_keyring.gpg"

    MOUNT_POINT=${BUILD_DIR}/mount_point

    OS="raspbian-buster-armhf"

    PIECES=(raspbian buster armhf)

    PIEMAN_DIR="."

    PM_OPTIONS=""

    PROJECT_NAME="mock_project"

    PYTHON="$(command -v python3)"

    R=${BUILD_DIR}/${PROJECT_NAME}/chroot

    SOURCE_DIR="${ROOT_DIR}/devices/rpi-3-b/${OS}"

    TOOLSET_CODENAME="mock_toolset"

    TOOLSET_DIR="${PIEMAN_DIR}/toolset"

    TOOLSET_FULL_PATH="${TOOLSET_DIR}/${TOOLSET_CODENAME}"

    USR_BIN="${R}/usr/bin"

    YML_FILE="${SOURCE_DIR}/pieman.yml"

    FATAL="${text_in_red_color}Fatal${reset}"

    . ../essentials.sh

    for script in ../helpers/*.sh; do
        . ${script}
    done

    # Mock some of the helpers loaded above.
    . ./mocks.sh
}

tearDown() {
    rm -rf "${TOOLSET_FULL_PATH}"
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

test_checking_if_wpa_psk_is_valid() {
    local result=""

    export WPA_PSK="secret"
    result=$((check_if_wpa_psk_is_valid) 2>&1)

    assertEquals "${FATAL}: WPA_PSK is not valid: passphrase must be 8..63 characters" "${result}"

    export WPA_PSK="42 is the answer to the Ultimate Question of Life, the Universe and Everything"
    result=$((check_if_wpa_psk_is_valid) 2>&1)

    assertEquals "${FATAL}: WPA_PSK is not valid: passphrase must be 8..63 characters" "${result}"

    export WPA_PSK="$(printf "42 is the\nanswer")"
    result=$((check_if_wpa_psk_is_valid) 2>&1)

    assertEquals "${FATAL}: WPA_PSK is not valid: invalid passphrase character" "${result}"

    export WPA_PSK="42 is the answer"
    result=$((check_if_wpa_psk_is_valid) 2>&1)

    assertNull "${result}"
}

test_checking_mutually_exclusive_params() {
    local output=""

    export PARAM1="true"

    { output="$((check_mutually_exclusive_params PARAM1 PARAM2 PARAM3) 2>&1)"; exit_code="$?"; } || true

    assertNull "${output}"
    assertTrue "[[ ${exit_code} -eq ${SHUNIT_TRUE} ]]"

    export PARAM2="true"
    export PARAM3="true"

    { output="$((check_mutually_exclusive_params PARAM1 PARAM2 PARAM3) 2>&1)"; exit_code="$?"; } || true

    assertEquals "${FATAL}: PARAM1 and PARAM2 conflict with each other." "${output}"
    assertTrue "[[ ${exit_code} -eq ${SHUNIT_FALSE} ]]"
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

    assertTrue "[ -n "${compressor}" ]"

    assertFalse "[ ! -z "${compressor}" ]"

    assertFalse "[[ -n ${compressor} ]]"
}

test_checking_if_debootstrap_is_uptodate() {
    mkdir -p "${TOOLSET_FULL_PATH}"/debootstrap/debian
    touch "${TOOLSET_FULL_PATH}"/debootstrap/debootstrap

    result=$((is_debootstrap_uptodate) 2>&1)

    # There must be an error because there is no changelog
    assertNotNull "$(echo ${result} | grep "Could not get its version")"

    echo "debootstrap (1.0.90) unstable; " \
         "urgency=medium" > "${TOOLSET_FULL_PATH}"/debootstrap/debian/changelog

    # There must be an error because the version of debootstrap is less than
    # required
    is_debootstrap_uptodate
    assertTrue "[ $? -eq ${SHUNIT_FALSE} ]"

    echo "debootstrap (${DEBOOTSTRAP_VER}) unstable; " \
         "urgency=medium" > "${TOOLSET_FULL_PATH}"/debootstrap/debian/changelog

    # Everything must me fine
    is_debootstrap_uptodate
    assertTrue "[ $? -eq ${SHUNIT_TRUE} ]"
}

test_choosing_user_mode_emulation_binary() {
    PIECES=(raspbian buster armhf)

    choose_user_mode_emulation_binary

    assertEquals "${TOOLSET_FULL_PATH}"/qemu-user-static/qemu-arm-static ${EMULATOR}

    PIECES=(raspbian buster arm64)

    choose_user_mode_emulation_binary

    assertEquals "${TOOLSET_FULL_PATH}"/qemu-user-static/qemu-aarch64-static ${EMULATOR}

    PIECES=(raspbian buster mock)

    local result=$((choose_user_mode_emulation_binary) 2>&1)

    assertEquals "${FATAL}: Unknown architecture mock." "${result}"
}

test_creating_dependent_params() {
    local result=""
    local error_msg="${FATAL}: A depends on B, so the latter must be set to true (if bool) or simply specified (in other cases)."

    export A="value1"
    result=$((depend_on A B) 2>&1)

    assertEquals "${error_msg}" "${result}"

    export A=false
    result=$((depend_on A B) 2>&1)

    # There is no need to check the dependency param if the dependent param is
    # set to false or not simply specified.
    assertNull "${result}"

    export A="value1"
    export B=false
    result=$((depend_on A B) 2>&1)

    # Check the case when the dependency param is set to false. It must be
    # considered as not specified.
    assertEquals "${error_msg}" "${result}"

    export A="value1"
    export B="value2"
    result=$((depend_on A B) 2>&1)

    assertNull "${result}"
}

test_getting_attr() {
    output="$(get_attr "${OS}" kernel package)"
    assertTrue "[ $? -eq ${SHUNIT_TRUE} ]"
    assertEquals "raspberrypi-kernel" "${output}"

    { output="$(get_attr "${OS}" some_attr 2>&1)"; exit_code="$?"; } || true
    assertTrue "[ ${exit_code} -eq ${SHUNIT_FALSE} ]"
    [[ "${output}" =~ "raspbian-buster-armhf does not have attribute some_attr." ]]
    assertTrue "[ $? -eq ${SHUNIT_TRUE} ]"
}

test_rendering() {
    local result=""

    result=$((render "${PIEMAN_DIR}/files/hosts.j2" "${PIEMAN_DIR}/files/hosts") 2>&1)

    assertNull "${result}"

    assertEquals "$(<"${PIEMAN_DIR}"/files/hosts)" "127.0.1.1 default"

    export HOST_NAME="pieman"
    result=$((render "${PIEMAN_DIR}/files/hosts.j2" "${PIEMAN_DIR}/files/hosts") 2>&1)

    assertNull "${result}"

    assertEquals "$(<"${PIEMAN_DIR}"/files/hosts)" "127.0.1.1 ${HOST_NAME}"

    result=$((render "${PIEMAN_DIR}/files/hosts.j2" "${PIEMAN_DIR}/some-non-existent-path/hosts") 2>&1)

    assertEquals "${FATAL}: rendering error: ./some-non-existent-path does not exist" "${result}"

    result=$((render "${PIEMAN_DIR}/stub.j2" "${PIEMAN_DIR}/stub") 2>&1)

    assertEquals "${FATAL}: rendering error: ./stub.j2 does not exist" "${result}"
}

test_running_first_stage() {
    run_first_stage

    assertEquals \
        "${DEBOOTSTRAP_CMD_LINE}" \
        "--arch=${PIECES[2]} --foreign --variant=minbase --keyring=${KEYRING} ${PIECES[1]} build/${PROJECT_NAME}/chroot http://archive.raspbian.org/raspbian"

    BASE_PACKAGES=mc,htop
    run_first_stage

    assertEquals \
        "${DEBOOTSTRAP_CMD_LINE}" \
        "--arch=${PIECES[2]} --foreign --variant=minbase --keyring=${KEYRING} --include=${BASE_PACKAGES} ${PIECES[1]} build/${PROJECT_NAME}/chroot http://archive.raspbian.org/raspbian"
}

test_splitting_os_name_into_pieces() {
    split_os_name_into_pieces

    YML_FILE="${ROOT_DIR}/devices/rpi-3-b/${OS}/pieman.yml"
    assertEquals "raspbian buster armhf" "${PIECES[*]}"

    OS="ubuntu-bionic-arm64"
    YML_FILE="${ROOT_DIR}/devices/rpi-3-b/${OS}/pieman.yml"
    split_os_name_into_pieces
    assertEquals "ubuntu bionic arm64" "${PIECES[*]}"

    OS="kali-rolling-armhf"
    YML_FILE="${ROOT_DIR}/devices/opi-pc-plus/${OS}/pieman.yml"
    split_os_name_into_pieces
    assertEquals "kali kali-rolling armhf" "${PIECES[*]}"
}

. $(command -v shunit2)

