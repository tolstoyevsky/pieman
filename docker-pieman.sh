#!/bin/bash
# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
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

set -e

if [[ ${BASH_VERSION} != 4.* ]]; then
    >&2 echo "$0 requires bash 4 and higher"
    exit 1
fi

x=0
while getopts e: OPTION
do
    case ${OPTION} in
    e)
        VARS[$x]=$OPTARG
        x=$((x + 1))
        ;;
    esac
done

ARGS=()
for var in ${VARS[@]}; do
    IFS='=' read -ra VAR_VALUE <<< ${var}
    if [[ ${#VAR_VALUE[@]} != 2 ]]; then
        >&2 echo "To assign environment variables, specify them as VAR=VALUE."
        exit 1
    fi

    ARGS+=(--env=${var})
done

docker run \
    --privileged --rm ${ARGS[@]} -v `pwd`:/result -v /dev:/dev cusdeb/pieman
