#!/bin/bash
# Copyright (C) 2017-2021 Evgeny Golyshev <eugulixes@gmail.com>
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

# The script must be run only after 11-pm.sh and 12-kernel.sh because it
# requires some of the files which are available only after installation all
# of the specified packages, including the kernel package.

# Get the files, which must present on the boot partition, from different
# sources and put them in the directory specified via BOOT.
boot="$(get_attr boot)"
for f in ${boot}; do
    if echo "${f}" | grep -Eq "^https://|^http://|^ftp://"; then
        info "downloading ${f} to ${BOOT}"
        do_wget -q -O "${BOOT}/$(basename "${f}")" "${f}"
    elif [[ ${f:0:1} == "/" ]]; then
        # Split the name of the target file or directory into two parts:
        # original name and copy name.
        IFS=':' read -ra FILE_NAMES <<< "${R}/${f}"

        info "copying ${FILE_NAMES[0]} to ${BOOT}"

        if [ -z "${FILE_NAMES[1]}" ]; then
            # If the name of the copy is not specified, use the original one.

            # globbing doesn't work when quoted, so
            # shellcheck disable=SC2086
            cp -r ${FILE_NAMES[0]} "${BOOT}"
        else
            info "$(basename "${FILE_NAMES[0]}") was renamed into ${FILE_NAMES[1]}"

            # shellcheck disable=SC2086
            cp -r ${FILE_NAMES[0]} "${BOOT}/${FILE_NAMES[1]}"
        fi
    else
        info "copying $(dirname "${YML_FILE}")/${f} to ${BOOT}"
        cp "${SOURCE_DIR}/${f}" "${BOOT}"
    fi
done

send_request_to_bsc_server PREPARED_BOOT_PARTITION_CODE
