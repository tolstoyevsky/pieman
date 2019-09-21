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

# Checks if the specified WPA passphrase is valid.
# Globals:
#     PIEMAN_UTILS_DIR
#     PYTHON
#     WPA_PSK
# Arguments:
#     Name of the environment variable, containing the WPA passphrase
# Returns:
#     None
check_if_wpa_psk_is_valid() {
    local error_msg="WPA_PSK is not valid: "

    { ${PYTHON} "${PIEMAN_UTILS_DIR}"/check_wpa_passphrase.py "${WPA_PSK}"; exit_code="$?"; } || true
    case "${exit_code}" in
    0)
        ;;
    1)
        fatal "${error_msg}passphrase must be 8..63 characters"
        exit 1
        ;;
    2)
        fatal "${error_msg}invalid passphrase character"
        exit 1
        ;;
    *)
        fatal "${error_msg}unknown error"
        exit 1
        ;;
    esac
}

# Invokes wpa_passphrase if both WPA_SSID and WPA_PSK are specified. If WPA_PSK
# is not specified (or it's empty), the network is considered as open, so the
# function prepares and returns a string, containing a network block which
# allows the target device to be connected to the open network.
# Globals:
#     R
#     WPA_SSID
#     WPA_PSK
# Arguments:
#     None
# Returns:
#     String, containing a network block
do_wpa_passphrase() {
    if [[ -n ${WPA_SSID} ]] && [[ -n ${WPA_PSK} ]]; then
        chroot "${R}" wpa_passphrase "${WPA_SSID}" "${WPA_PSK}"
    else
        echo "network={"
        echo "    ssid=\"${WPA_SSID}\""
        echo "    key_mgmt=NONE"
        echo "}"
    fi
}
