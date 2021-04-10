# Copyright (C) 2019 Eduard Lemmer <d-s-lemmer@gmail.com>
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

if ${XFCE4}; then 
    install_exec "${PIEMAN_DIR}"/files/desktop/06xfce4.desktop "${R}"/usr/share/xsessions/06xfce4.desktop
fi

if ${XFCE4}; then
    install_exec "${PIEMAN_DIR}"/files/desktop/lxdm.conf "${R}"/etc/lxdm.conf
fi