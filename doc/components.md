# Components

Pieman is divided into toolset, utilities and Pieman itself. The page is devoted to the first two.

## Toolset

To build an operating system image, Pieman must seek assistance from different tools. For example, every single operating system image is unthinkable without a chroot environment it's based on. To build a Debian-based chroot environment, one must use the tool named [debootstrap](https://salsa.debian.org/installer-team/debootstrap). The tool can be easily obtained in Alpine, Debian/Ubuntu, Fedora and other distributions via their repositories, but there is one problem here – not always the version of debootstrap will be suitable for preparing chroot environments of newest distributions, because it will generally be outdated. Pieman undertakes the task to install the required version of this and other tools. When the tools come together, they form something which has been named *toolset* in Pieman.

Not to make the section debootstrap-oriented, I suggest we will have a look at other tools which are part of the Pieman toolset.
* [apk.static](https://wiki.alpinelinux.org/wiki/Installing_Alpine_Linux_in_a_chroot) is used to prepare the chroot environments based on Alpine Linux.
* [Das U-Boot](https://denx.de/wiki/U-Boot) and related utilities are used to make booting the built images on some single-board computers possible. 

## Utilities

The larger part of Pieman is written in Bash. The main task of Pieman is to run a certain program (`dd`, `parted`, etc) with certain options under certain conditions and Bash does a great job of doing this. However, the certain program does not always exist. In this case the Pieman utilities come to the rescue. The utilities are
* written in Python;
* distributed in the Python package named [pieman](https://pypi.org/project/pieman/);
* built in the best tradition of Unix – do one thing and do it well (there is one particular program for one particular task).

Since Pieman depends on Python it tries to make the most of the interpreter. Thus, the pieman package contains alternatives written in Python for well-known programs, such as `uuidgen` and GNU [Wget](https://gnu.org/software/wget/). It helps keeping the Pieman dependencies list as compact as possible.
