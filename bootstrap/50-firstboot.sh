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

check_if_variable_is_set ETC

if is_alpine; then
    info "Adding the local service to the default runlevel"
    chroot_exec rc-update add local default
fi

info "Preparing ${FIRSTBOOT}"

touch "${FIRSTBOOT}"
chmod +x "${FIRSTBOOT}"

for script in files/firstboot/*.sh; do
    cat ${script} >> "${FIRSTBOOT}"
done

if is_alpine; then
    install_exec "${FIRSTBOOT}" ${ETC}/local.d/90-firstboot.start
    echo "rm -f /etc/local.d/90-firstboot.start" >> ${ETC}/local.d/90-firstboot.start
elif is_debian_based; then
    install_exec "${FIRSTBOOT}" ${ETC}/rc.firstboot
    install_exec files/etc/rc.local ${ETC}/rc.local

    # /etc/rc.firstboot has to destroy itself and its traces after first run.
    cat <<EOT >> ${ETC}/rc.firstboot
rm -f /etc/rc.firstboot
sed -i '/.*rc.firstboot/d' /etc/rc.local
EOT

    sed -i "/exit 0/d" ${ETC}/rc.local
    echo "/etc/rc.firstboot" >> ${ETC}/rc.local
    echo "exit 0" >> ${ETC}/rc.local
fi
