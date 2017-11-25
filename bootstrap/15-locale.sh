# Copyright (C) 2017 Denis Mosolov <denismosolov@cusdeb.com>
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

if ! check_if_variable_is_set TIME_ZONE; then
    >&2 echo "TIME_ZONE is not specified"
    exit 1
fi

# Set timezone
# https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
chroot_exec ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime
chroot_exec dpkg-reconfigure -f noninteractive tzdata
