# Copyright (C) 2020 Dmitriy Ivanko <tmwsls12@gmail.com>
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

check_mutually_exclusive_params \
    BASE_DIR \
    CREATE_ONLY_CHROOT

check_mutually_exclusive_params \
    ENABLE_GOOGLE_DNS \
    ENABLE_BASIC_YANDEX_DNS \
    ENABLE_FAMILY_YANDEX_DNS \
    ENABLE_CUSTOM_DNS

check_mutually_exclusive_params \
    COMPRESS_WITH_BZIP2 \
    COMPRESS_WITH_GZIP \
    COMPRESS_WITH_XZ

check_mutually_exclusive_params \
    CREATE_ONLY_MENDER_ARTIFACT \
    CREATE_ONLY_CHROOT \
    ENABLE_MENDER
