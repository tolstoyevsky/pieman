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

ALPINE_VER="3.9"

DEBOOTSTRAP_VER="1.0.105"

MENDER_ARTIFACT_VER="2.3.0"

MENDER_CLIENT_VER="1.7.0"

MENDER_CLIENT_REPO="https://raw.githubusercontent.com/mendersoftware/mender"

MENDER_CLIENT_REVISION="1.7.x"

PIEMAN_MAJOR_VER=0

PIEMAN_MINOR_VER=6

PYTHON_MAJOR_VER=3

PYTHON_MINOR_VER=5

UBOOT_MENDOR_BRANCH="mender-rpi-2017.09"

UBOOT_MENDOR_COMMIT="988e0ec54"

text_in_red_color=$(tput setaf 1)

text_in_green_color=$(tput setaf 2)

text_in_yellow_color=$(tput setaf 3)

reset=$(tput sgr0)

# Images types

IMAGE_FOR_RPI=1

IMAGE_FOR_RPI_WITH_MENDER_CLIENT=2

IMAGE_MENDER_ARTIFACT=3

# Checks if the specified variable is set.
# Globals:
#     None
# Arguments:
#     Variable name
# Returns:
#     Boolean
check_if_variable_is_set() {
    var_name=$1
    if [ -z "${!var_name+x}" ]; then
        false
    else
        true
    fi
}

# Prints the specified message with the level fatal.
# Globals:
#     None
# Arguments:
#     Message
# Returns:
#     None
fatal() {
    >&2 echo "${text_in_red_color}Fatal${reset}: ${*}"
}

# Prints the specified message with the level info.
# Globals:
#     None
# Arguments:
#     Message
# Returns:
#     None
info() {
    >&2 echo "${text_in_yellow_color}Info${reset}: ${*}"
}

# Prints the specified message with the level success.
# Globals:
#     None
# Arguments:
#     Message
# Returns:
#     None
success() {
    >&2 echo "${text_in_green_color}Success${reset}: ${*}"
}

# Defines variable assigning the specified value to it if the variable does not
# exist. The function is a kind of shortcut for
#   set -x
#   VAR_NAME=${VAR_NAME:="default value"}
#   set +x
# Globals:
#     None
# Arguments:
#     Variable name
#     Value by default
# Returns:
#     None
def_var() {
    local var_name=$1
    local value=$2

    if check_if_variable_is_set ${var_name}; then
        value="${!var_name}"
    fi

    eval export ${var_name}="\"${value}\""

    >&2 echo "+ ${var_name}=${value}"
}

# Acts like def_var but places further restrictions on the target value: it
# must be integer.
# Globals:
#     None
# Arguments:
#     Variable name
#     Value by default
# Returns:
#     None
def_int_var() {
    local var=$1
    local val=$2
    local re="^[0-9]+$"

    def_var "${var}" "${val}"

    if ! [[ "${!var}" =~ ${re} ]] ; then
        fatal "${var} must be an integer"
        exit 1
    fi
}

# Defines variable assigning the specified value to it if the variable does not
# exist. If the variable equals to "-", the function will suggest entering the
# value without echo.
# The function behaviour is very similar to def_var, but it always prints to
# stderr
#   + VAR_NAME=*****
# hiding the real value.
# Globals:
#     None
# Arguments:
#     Variable name
#     Value by default
# Returns:
#     None
def_protected_var() {
    local var_name=$1
    local value=$2

    if check_if_variable_is_set ${var_name}; then
        value="${!var_name}"

        if [ "${value}" = "-" ]; then
            read -s -p "Enter ${var_name} value: " value
            echo
        fi
    fi

    eval ${var_name}="\"${value}\""

    >&2 echo "+ ${var_name}=*****"
}

# Acts like def_var but additionally requires that the target value is Boolean.
# Globals:
#     None
# Arguments:
#     Variable name
#     Value by default
# Returns:
#     None
def_bool_var() {
    local var=$1
    local val=$2
    
    def_var "${var}" "${val}"

    if [[ "${!var}" != "true" ]] && [[ "${!var}" != "false" ]]; then
        fatal "${var} must be a boolean"
        exit 1
    fi
}


# Gets the ownership of the specified file or directory.
# Globals:
#     None
# Arguments:
#     File name or directory name
# Returns:
#     Ownership in format "uid:gid"
get_ownership() {
    echo "$(id -u "$(stat -c "%U" "$1")"):$(id -g "$(stat -c "%G" "$1")")"
}

# Runs all scripts which are located in the specified directory.
# Globals:
#     None
# Arguments:
#     Path to the directory
# Returns:
#     None
run_scripts() {
    dir=${1}
    if [ -d ${dir} ]; then
        for script in ${dir}/*.sh; do
            info "running ${script} from ${dir}"
            . ${script}
        done
    else
        info "cannot run anything from ${dir} since it does not exist."
    fi
}

# Splits the value of the OS variable into pieces and stores it to the PIECES
# array. OS must stick to the following naming convention:
# <distro name>-<codename>-<arch>.
# Globals:
#     None
# Arguments:
#     OS
#     PIECES
# Returns:
#     None
split_os_name_into_pieces() {
    # shellcheck disable=SC2034
    IFS='-' read -ra PIECES <<< ${OS}
}

# Writes "yes" or "no" to stderr depending on the condition.
# Globals:
#     None
# Arguments:
#     Condition
# Returns:
#     0 or 1 depending on the condition.
yes_or_no() {
    if $(eval $1); then
        >&2 echo "yes"
        return 0
    else
        >&2 echo "no"
        return 1
    fi
}
