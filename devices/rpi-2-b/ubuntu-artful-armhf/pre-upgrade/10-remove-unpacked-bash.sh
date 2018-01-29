set -e

check_if_variable_is_set R

# Remove unpacked bash.
chroot_exec_sh "dpkg -c /var/cache/apt/archives/bash_*.deb" | while IFS= read -r line; do
    f=`echo ${line} | awk '{print $6}' | sed -e "s/^.//"`
    if [ -f "${R}/${f}" ]; then
        rm "${R}/${f}"
    fi
done

# Put bash on hold to avoid installing it on dist-upgrade.
chroot_exec apt-mark hold bash
