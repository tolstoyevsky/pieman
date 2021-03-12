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
    TEST_DIR="$( dirname "$(readlink -f "$0")" )"

    PIEMAN_DIR="${PIEMAN_DIR:=$(pwd)}"

    BUILD_DIR="build"

    IMAGE="${BUILD_DIR}/mock_image.img"

    KEYRING="mock_keyring.gpg"

    MOUNT_POINT=${BUILD_DIR}/mount_point

    PROJECT_NAME="mock_project"

    PYTHON="$(command -v python3)"

    TOOLSET_CODENAME="mock_toolset"

    TOOLSET_DIR="${TEST_DIR}/toolset"

    TOOLSET_FULL_PATH="${TOOLSET_DIR}/${TOOLSET_CODENAME}"

    FATAL="${text_in_red_color}Fatal${reset}"

    . "${PIEMAN_DIR}"/essentials.sh

    for script in "${PIEMAN_DIR}"/helpers/*.sh; do
        . ${script}
    done

    # Mock some of the helpers loaded above.
    . "${TEST_DIR}"/mocks.sh
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
    R=chroot

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
    assertFalse "[[ -n ${compressor} ]]"
}

test_checking_if_debootstrap_is_uptodate() {
    DEBOOTSTRAP_EXEC="debootstrap_mock"

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
    assertTrue "[[ $? -eq ${SHUNIT_FALSE} ]]"

    echo "debootstrap (${DEBOOTSTRAP_VER}) unstable; " \
         "urgency=medium" > "${TOOLSET_FULL_PATH}"/debootstrap/debian/changelog

    # Everything must me fine
    is_debootstrap_uptodate
    assertTrue "[[ $? -eq ${SHUNIT_TRUE} ]]"
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
    local output=""

    OS="ubuntu-focal-armhf"

    YML_FILE="${TEST_DIR}/assets/${OS}_pieman.yml"

    output="$(get_attr "${OS}" kernel package)"
    assertTrue "[[ $? -eq ${SHUNIT_TRUE} ]]"
    assertEquals "linux-image-raspi2" "${output}"

    { output="$(get_attr "${OS}" some_attr 2>&1)"; exit_code="$?"; } || true
    assertTrue "[[ ${exit_code} -eq ${SHUNIT_FALSE} ]]"

    [[ "${output}" =~ "${OS} does not have attribute some_attr." ]]
    assertTrue "[[ $? -eq ${SHUNIT_TRUE} ]]"
}

test_rendering() {
    local result=""

    result=$((render "${TEST_DIR}/assets/hosts.j2" "${TEST_DIR}/assets/hosts") 2>&1)

    assertNull "${result}"

    assertEquals "$(<"${TEST_DIR}"/assets/hosts)" "127.0.1.1 default"

    export HOST_NAME="pieman"
    result=$((render "${TEST_DIR}/assets/hosts.j2" "${TEST_DIR}/assets/hosts") 2>&1)

    assertNull "${result}"

    assertEquals "$(<"${TEST_DIR}"/assets/hosts)" "127.0.1.1 ${HOST_NAME}"

    result=$((render "${TEST_DIR}/assets/hosts.j2" "${TEST_DIR}/some-non-existent-path/hosts") 2>&1)

    assertEquals "${FATAL}: rendering error: ${TEST_DIR}/some-non-existent-path does not exist" "${result}"

    result=$((render "${TEST_DIR}/stub.j2" "${TEST_DIR}/stub") 2>&1)

    assertEquals "${FATAL}: rendering error: ${TEST_DIR}/stub.j2 does not exist" "${result}"
}

test_running_first_stage() {
    OS="ubuntu-focal-armhf"

    PIECES=(raspbian buster armhf)

    R=chroot

    run_first_stage

    assertEquals \
        "${DEBOOTSTRAP_CMD_LINE}" \
        "--arch=${PIECES[2]} --foreign --variant=minbase --keyring=${KEYRING} ${PIECES[1]} ${R} http://ports.ubuntu.com/ubuntu-ports/"

    BASE_PACKAGES=mc,htop
    run_first_stage

    assertEquals \
        "${DEBOOTSTRAP_CMD_LINE}" \
        "--arch=${PIECES[2]} --foreign --variant=minbase --keyring=${KEYRING} --include=${BASE_PACKAGES} ${PIECES[1]} ${R} http://ports.ubuntu.com/ubuntu-ports/"
}

test_splitting_os_name_into_pieces() {
    OS="ubuntu-focal-armhf"

    YML_FILE="${TEST_DIR}/assets/${OS}_pieman.yml"

    split_os_name_into_pieces
    assertEquals "ubuntu focal armhf" "${PIECES[*]}"

    OS="kali-rolling-armhf"

    YML_FILE="${TEST_DIR}/assets/${OS}_pieman.yml"

    split_os_name_into_pieces
    assertEquals "kali kali-rolling armhf" "${PIECES[*]}"
}

. $(command -v shunit2)

