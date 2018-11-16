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

ALPINE_VER="3.7"

DEBOOTSTRAP_VER="1.0.105"

PIEMAN_MAJOR_VER=0

PIEMAN_MINOR_VER=4

PYTHON_MAJOR_VER=3

PYTHON_MINOR_VER=5

text_in_red_color=$(tput setaf 1)

text_in_green_color=$(tput setaf 2)

text_in_yellow_color=$(tput setaf 3)

reset=$(tput sgr0)

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

    eval ${var_name}="\"${value}\""

    >&2 echo "+ ${var_name}=${value}"
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
