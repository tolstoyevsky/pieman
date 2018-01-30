# Pieman [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Create%20a%20custom%20OS%20image%20for%20for%20your%20Raspberry%20Pi&url=https://github.com/tolstoyevsky/pieman&via=CusDeb&hashtags=RaspberryPi,Raspbian,Ubuntu)

<p align="center">
    <img src="/logo/380x400.png" alt="Pieman">
</p>

Pieman is a script for creating custom OS images for single-board computers such as Raspberry Pi. The images are based on Debian GNU/Linux and its derivatives at this time. The authors of Pieman were inspired by the project named [rpi23-gen-image](https://github.com/drtyhlpr/rpi23-gen-image). The main reason why it was decided to create a new project instead of improving the existing one is that rpi23-gen-image is intended for creating images only for Raspberry Pi 2 and 3 based on Debian GNU/Linux. Unfortunately, it doesn't have a way to be extended to support different operating systems and single-board computers. Improving the situation would require significant efforts to rework the codebase of the project.

## Table of Contents

- [Getting Started](#getting-started)
  * [Dependencies](#dependencies)
  * [Supported platforms](#supported-platforms)
  * [Installation](#installation)
    + [Docker](#docker)
    + [Manual](#manual)
- [Documentation](#documentation)
- [Authors](#authors)
- [Licensing](#licensing)
- [Contribute](#contribute)

## Getting Started

### Dependencies

* debootstrap
* dosfstools
* dpkg
* GNU Parted
* GnuPG
* mkpasswd
* Python 3
* PyYAML
* rsync
* Setuptools
* uuidgen
* User mode emulation binaries such as `/usr/bin/qemu-arm-static` and `/usr/bin/qemu-aarch64-static`
* wget

### Supported platforms

Theoretically, Pieman can be run on any GNU/Linux, however, it was very carefully tested only on:
* Debian 9 «Stretch»
* Fedora 26
* Ubuntu 16.04 «Xenial Xerus»

### Installation

#### Docker

First, get the latest Pieman Docker image from Docker Hub.

```
$ docker pull cusdeb/pieman
```

Then, get `docker-pieman.sh`

```
$ wget https://raw.githubusercontent.com/tolstoyevsky/pieman/master/docker-pieman.sh -O docker-pieman.sh
```

or using `curl`

```
$ curl -o docker-pieman.sh https://raw.githubusercontent.com/tolstoyevsky/pieman/master/docker-pieman.sh
```

Note, that the script requires bash 4 or higher, so macOS users should upgrade their bash if they haven't done it yet.

##### Usage

Simply run `docker-pieman.sh` to create an image based on Raspbian Stretch for Raspberry Pi 3.

```
$ chmod +x docker-pieman.sh
$ ./docker-pieman.sh
```

Under the hood the script runs

```
$ docker run --privileged --rm -v $(pwd):/result -v /dev:/dev cusdeb/pieman
```

It's quite wordy, isn't it? `docker-pieman.sh` is intended to hide the details and provide an easy-to-use command-line interface.

Another example shows how to create an image based on Ubuntu Xenial for Raspberry Pi 2 with [htop](https://packages.debian.org/stretch/htop) and [mc](https://packages.debian.org/stretch/mc) pre-installed

```
$ ./docker-pieman.sh -e DEVICE=rpi-2-b -e OS=ubuntu-xenial-armhf -e INCLUDES=htop,mc
```

The built images will be located in the current directory. By the way, you can specify the name of your project via the `PROJECT_NAME` environment variable. You can find details on `DEVICE`, `INCLUDES`, `OS`, `PROJECT_NAME` and other environment variables (called parameters) which help customizing images in the Documentation section.

#### Manual

First, clone the Pieman git repo:

```
$ git clone https://github.com/tolstoyevsky/pieman.git
```

Then, go into the newly created directory and clone the debootstrap git repo there. Pieman requires debootstrap `1.0.91 `or higher.

```
$ cd pieman
$ git clone https://anonscm.debian.org/git/d-i/debootstrap.git
$ cd debootstrap
$ git checkout 1.0.91
```

If your distribution has debootstrap 1.0.91 or higher (for example, Ubuntu 17.10), you can skip this step and install it via a package manager.

Next, install the rest of the Pieman dependencies.

On Debian or Ubuntu:

```
$ sudo apt-get install dosfstools gnupg parted python3-setuptools python3-yaml qemu-user-static rsync uuid-runtime wget whois
```

On Fedora:

```
$ sudo dnf install dosfstools dpkg expect gpg parted python3-PyYAML python3-setuptools qemu-user-static rsync wget
```

Finally, return to the project directory and run

```
$ sudo python3 setup.py install
```

to install the required utilities and modules written in Python.

##### Usage

Go to the project directory and execute the following command to create an image based on Raspbian Stretch for Raspberry Pi 3:

```
$ sudo ./pieman.sh
```

To create an image based on Ubuntu Xenial for Raspberry Pi 2 with [htop](https://packages.debian.org/stretch/htop) and [mc](https://packages.debian.org/stretch/mc) pre-installed run

```
$ sudo env DEVICE=rpi-2-b OS=ubuntu-xenial-armhf INCLUDES=htop,mc ./pieman.sh
```

The built images will be located in `build/<project name>`. By the way, you can specify the name of your project via the `PROJECT_NAME` environment variable. You can find details on `DEVICE`, `INCLUDES`, `OS`, `PROJECT_NAME` and other environment variables (called parameters) which help customizing images in the Documentation section.

## Documentation

|                                                                                             | Devuan 1 «Jessie»     | Raspbian 9 «Stretch»  | Ubuntu 16.04 «Xenial Xerus» | Ubuntu 17.10 «Artful Aardvark» |
|---------------------------------------------------------------------------------------------|:---------------------:|:---------------------:|:---------------------------:|:------------------------------:|
| Raspberry Pi [Model B and B+](https://www.raspberrypi.org/products/raspberry-pi-1-model-b/) |                       | 32bit                 |                             |                                |
| Raspberry Pi [2 Model B](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/)      | 32bit                 | 32bit                 | 32bit                       | 32bit                          |
| Raspberry Pi [3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)      | 32bit                 | 32bit                 |                             | 32bit, 64bit                   |
| Raspberry Pi [Zero](https://www.raspberrypi.org/products/raspberry-pi-zero/)                |                       | 32bit                 |                             |                                |

The operating system of the target image is specified via the `OS` environment variable. The next table maps full names of the supported operating systems to their short name intended for using as values of `OS`.

| Full name                               | Short name             |
|-----------------------------------------|------------------------|
| Devuan 1 «[Jessie](https://lists.dyne.org/lurker/message/20170525.180739.f86cd310.en.html#devuan-announce)» (32-bit) | devuan-jessie-armhf |
| Raspbian 9 «[Stretch](https://raspberrypi.org/blog/raspbian-stretch/)» (32-bit)           | raspbian-stretch-armhf |
| Ubuntu 16.04 «[Xenial Xerus](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes)» (32-bit)    | ubuntu-xenial-armhf    |
| Ubuntu 17.10 «[Artful Aardvark](https://wiki.ubuntu.com/ArtfulAardvark/ReleaseNotes)» (32-bit) | ubuntu-artful-armhf    |
| Ubuntu 17.10 «[Artful Aardvark](https://wiki.ubuntu.com/ArtfulAardvark/ReleaseNotes)» (64-bit) | ubuntu-artful-arm64    |

The device the target image is created for is specified via the `DEVICE` environment variable. The next table maps full names of the supported devices to their short name intended for using as values of `DEVICE`.

| Full name                   | Short name |
|-----------------------------|------------|
| Raspberry Pi Model B and B+ | rpi-b      |
| Raspberry Pi 2 Model B      | rpi-2-b    |
| Raspberry Pi 3 Model B      | rpi-3-b    |
| Raspberry Pi Zero           | rpi-zero   |

### Parameters

#### General

##### OS="raspbian-stretch-armhf"

Allows specifying the operating system to be used as a base for the target image. You can find all the possible values for the parameter in the table above (see the "Short name" column). 

##### DEVICE="rpi-3-b"

Allows specifying the device the image is going to be run on. You can find all the possible values for the parameter in the table above (see the "Short name" column).

##### BASE_DIR=""

Allows specifying the chroot environment to be used instead of creating a new one.

##### PROJECT_NAME="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

Each image is built in in the context of some project. The parameter allows specifying the project name. By default, the name is a randomly generated UUID 32-character string.

##### BUILD_DIR="build"

Allows specifying the projects location. By default, the directory named `build` is created in the current directory.

##### CREATE_ONLY_CHROOT=false

Makes Pieman restrict itself to creating only a chroot environment based on the operating system specified via `OS`. The chroot environment can be used immediately or later to reduce the time of building images. See `BASE_DIR`.

##### TIME_ZONE="Etc/UTC"

Specifies the time zone of the system.

---

#### Networking

##### ENABLE_GOOGLE_DNS=false

Enables the most common DNS server provided by Google.

The DNS IP addresses (IPv4) are the following:

* `8.8.8.8`
* `8.8.4.4`

Note, that the parameter conflicts with `ENABLE_BASIC_YANDEX_DNS`, `ENABLE_FAMILY_YANDEX_DNS` and `ENABLE_CUSTOM_DNS`.

##### ENABLE_BASIC_YANDEX_DNS=false

Enables a quick and reliable DNS server provided by Yandex.

The DNS IP addresses (IPv4) are the following:

* `77.88.8.8`
* `77.88.8.1`

Note, that the parameter conflicts with `ENABLE_GOOGLE_DNS`, `ENABLE_FAMILY_YANDEX_DNS` and `ENABLE_CUSTOM_DNS`.

##### ENABLE_FAMILY_YANDEX_DNS=false

Enables the DNS server provided by Yandex with protection from "adult" content.

* `77.88.8.7`
* `77.88.8.3`

Note, that the parameter conflicts with `ENABLE_GOOGLE_DNS`, `ENABLE_BASIC_YANDEX_DNS`, and `ENABLE_CUSTOM_DNS`.

##### ENABLE_CUSTOM_DNS=""

Enables a custom DNS server specified via this parameter.

Note, that the parameter conflicts with `ENABLE_GOOGLE_DNS`, `ENABLE_BASIC_YANDEX_DNS`, and `ENABLE_FAMILY_YANDEX_DNS`.

##### HOST_NAME="pieman-${DEVICE}"

Specifies the hostname of a device.

---

#### Package manager

##### ALLOW_UNAUTHENTICATED=false

Allows installing packages without checking their signatures.

##### ENABLE_NONFREE=false

This is a Debian-specific parameter. It enables the [non-free and contrib](https://wiki.debian.org/SourcesList#Component) sections in `/etc/apt/sources.list`. By default, only the main section is used. Sections are also called components or areas.

##### ENABLE_UNIVERSE=false

This is an Ubuntu-specific parameter. It enables the [universe](https://help.ubuntu.com/community/Repositories/Ubuntu#The_Four_Main_Repositories) section in `/etc/apt/sources.list`. By default, only the main section is used.

##### INCLUDES=""

A comma-separated list of the packages to be installed on the system specified via `OS`.

---

#### Users

##### ENABLE_SUDO=true

Installs `sudo`. If `ENABLE_USER` is set to `true`, Pieman adds the user `USER_NAME` to `/etc/sudoers`.

##### ENABLE_USER=true

Creates a non-root user `USER_NAME` with the password `USER_PASSWORD`.

##### PASSWORD="secret"

Allows specifying the root password. It's **HIGHLY RECOMMENDED** to change the default root password.

##### SUDO_REQUIRE_PASSWORD=true

Tells `sudo` whether it should prompt for the password.

It's necessary to disable the password prompts if you want to manage your device via, for example, [SSH Button](https://play.google.com/store/apps/details?id=com.pd7l.sshbutton).

##### USER_NAME="cusdeb"

Allows specifying a non-root user name. It's ignored if `ENABLE_USER` is set to `false`.

##### USER_PASSWORD="secret"

Allows specifying a non-root user password. It's ignored if `ENABLE_USER` is set to `false`. It's **HIGHLY RECOMMENDED** to change the default user password.

---

#### Pieman-specific

##### PYTHON="$(which python3)"

Allows specifying the Python 3 interpreter to be used when calling the Pieman-specific utilities. 

## Authors

See [AUTHORS](AUTHORS.md).

## Licensing

Pieman is available under the [GNU General Public License version 3](LICENSE).

Pieman borrows some pieces of code from rpi23-gen-image which are available under the [GNU General Public License version 2](https://gnu.org/licenses/old-licenses/gpl-2.0.txt).

## Contribute

If you want to contribute to Pieman, we encourage you to do so by sending a [pull request](https://github.com/tolstoyevsky/pieman/pulls).

In case you encounter any issues, please feel free to raise a [ticket](https://github.com/tolstoyevsky/pieman/issues)!

If you like Pieman and want to support it, then please star the project or watch it on GitHub.

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2AUE2GFWPX88S)
