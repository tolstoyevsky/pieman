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

if is_alpine; then
    # For some reason the rw parameter in cmdline.txt is ignored, so the rootfs
    # should be remounted at startup.
    install_exec files/etc/local.d/10-remount_root.start ${ETC}/local.d/10-remount_root.start

    # Since the system is already installed, the message may confuse users.
    sed -i '/You can setup the system/,+1d' "${ETC}/motd"

    # Of course, none of the supported single board computers has any cdrom.
    sed -i '/cdrom/d' "${ETC}/fstab"

    # Enable the agetty service, otherwise users won't see a login prompt when
    # accessing the console of their device through serial ports such as
    # /dev/ttyS0.
    create_symlink /etc/init.d/agetty /etc/init.d/agetty.ttyS0
    chroot_exec rc-update add agetty.ttyS0 default
fi


