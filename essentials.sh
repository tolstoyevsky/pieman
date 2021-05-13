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

ALPINE_VER="3.12"

DEBOOTSTRAP_VER="1.0.118"

MENDER_ARTIFACT_VER="2.3.0"

MENDER_CLIENT_VER="1.7.0"

MENDER_CLIENT_REPO="https://raw.githubusercontent.com/mendersoftware/mender"

MENDER_CLIENT_REVISION="1.7.x"

PIEMAN_MAJOR_VER=0

PIEMAN_MINOR_VER=19

PYTHON_MAJOR_VER=3

PYTHON_MINOR_VER=7

export UBOOT_VER="2019.01"

UBOOT_URL="ftp://ftp.denx.de/pub/u-boot/"

UBOOT_MENDER_BRANCH="mender-rpi-2017.09"

UBOOT_MENDER_COMMIT="988e0ec54"

text_in_red_color=$(tput setaf 1)

text_in_green_color=$(tput setaf 2)

text_in_yellow_color=$(tput setaf 3)

reset=$(tput sgr0)

# Images types

IMAGE_CLASSIC=1

IMAGE_WITH_MENDER_CLIENT=2

IMAGE_MENDER_ARTIFACT=3

# Activates the venv virtual environment if it exists.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     None
activate_venv_if_exists() {
    if [[ -d venv ]] && [[ -f venv/bin/python ]]; then
        info "activating the venv virtual environment"
        # shellcheck disable=SC1091
        source ./venv/bin/activate
    fi
}

# Checks if all required dependencies are installed on the system.
# Globals:
#     COMPRESS_WITH_BZIP2
#     PIEMAN_MAJOR_VER
#     PIEMAN_MINOR_VER
#     PYTHON
# Arguments:
#     None
# Returns:
#     None
check_dependencies() {
    if ! command -v dpkg > /dev/null; then
        # Do not mention Debian or Ubuntu since dpkg is a part of
        # the base system there.
        fatal "there is no dpkg. Run dnf install dpkg on Fedora to fix it."
        exit 1
    fi

    if ! command -v mkpasswd > /dev/null; then
        fatal "there is no mkpasswd. Run apt-get install whois on Debian/Ubuntu or dnf install expect on Fedora."
        exit 1
    fi

    if ! command -v xz > /dev/null; then
        fatal "there is no xz. Run apt-get install xz-utils on Debian/Ubuntu or dnf install xz on Fedora."
        exit 1
    fi

    if ! check_pieman_version; then
        fatal "Pieman package ${PIEMAN_MAJOR_VER}.${PIEMAN_MINOR_VER} or higher is required. Check the documentation on how to install or upgrade it."
        exit 1
    fi

    if ! check_python_version; then
        fatal "Python ${PYTHON_MAJOR_VER}.${PYTHON_MINOR_VER} or higher is required. $("${PYTHON}" -V) is used instead."
        exit 1
    fi

    if ${COMPRESS_WITH_BZIP2}; then
        if ! command -v bzip2 > /dev/null; then
            fatal "there is no bzip2. Run apt-get install bzip2 on Debian/Ubuntu or dnf install bzip2 on Fedora."
            exit 1
        fi
    fi
}

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

# Checks if the Pieman package version is equal or greater than required.
# Globals:
#     PIEMAN_MAJOR_VER
#     PIEMAN_MINOR_VER
#     PYTHON
# Arguments:
#     None
# Returns:
#     Boolean
check_pieman_version() {
    local pieman_version=(0 0)
    local output=""

    # Pieman package 0.1 doesn't have the __version__ module attribute, so we
    # have to provide for backwards compatibility.
    if output=$("${PYTHON}" -c "import pieman; print(pieman.__version__)" 2>&1); then
        IFS='.' read -ra pieman_version <<< "${output}"
    else
        case "${output}" in
        # When the script is run from the root of the source directory, it
        # considers the pieman directory as a package. In turn, if the pieman
        # package is not installed either globally or to a virtual environment,
        # AttributeError will be raised.
        *"AttributeError:"*)
            ;;
        *"ModuleNotFoundError:"*)
            ;;
        *)
            fatal "${output}"
            exit 1
        esac
    fi

    if (("${pieman_version[0]}" >= "${PIEMAN_MAJOR_VER}")) && (("${pieman_version[1]}" >= "${PIEMAN_MINOR_VER}")); then
        true
    else
        false
    fi
}

# Checks if the current Python version is equal or greater than required.
# Globals:
#     PYTHON_MAJOR_VER
#     PYTHON_MINOR_VER
#     PYTHON
# Arguments:
#     None
# Returns:
#     Boolean
check_python_version() {
    local current_python_version=()

    IFS='.' read -ra current_python_version <<< "$("${PYTHON}" -V | cut -d' ' -f2)"

    if (("${current_python_version[0]}" >= "${PYTHON_MAJOR_VER}")) && (("${current_python_version[1]}" >= "${PYTHON_MINOR_VER}")); then
        true
    else
        false
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

    eval export ${var_name}="\"${value}\""

    >&2 echo "+ ${var_name}=*****"
}

# Defines a private variable. The function helps avoid using shellcheck disable=SC2034
# Globals:
#     None
# Arguments:
#     Variable name
#     Value by default
# Returns:
#     None
def_private_var() {
    local var=$1
    local val=$2

    eval ${var}="\"${val}\""
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

# Creates a new UUID value.
# Globals:
#     PYTHON
# Arguments:
#     None
# Returns:
#     UUID value.
do_uuidgen() {
    "${PYTHON}" -c "import uuid; print(uuid.uuid4())"
}
