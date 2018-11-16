[![build](https://travis-ci.org/tolstoyevsky/pieman.svg?branch=master)](https://travis-ci.org/tolstoyevsky/pieman) [![](https://images.microbadger.com/badges/image/cusdeb/pieman.svg)](https://hub.docker.com/r/cusdeb/pieman/) [![](https://images.microbadger.com/badges/commit/cusdeb/pieman.svg)](https://hub.docker.com/r/cusdeb/pieman/)

# Pieman [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&logo=twitter)](https://twitter.com/intent/tweet?text=Create%20a%20custom%20OS%20image%20for%20for%20your%20Raspberry%20Pi&url=https://github.com/tolstoyevsky/pieman&via=CusDeb&hashtags=RaspberryPi,Raspbian,Ubuntu)

<p align="center">
    <img src="/logo/380x400.png" alt="Pieman">
</p>

Pieman is a script for creating custom OS images for single-board computers such as Raspberry Pi. The authors of Pieman were inspired by the project named [rpi23-gen-image](https://github.com/drtyhlpr/rpi23-gen-image). The main reason why it was decided to create a new project instead of improving the existing one is that rpi23-gen-image is intended for creating images only for Raspberry Pi 2 and 3 based on Debian GNU/Linux. Unfortunately, it doesn't have a way to be extended to support different operating systems and single-board computers. Improving the situation would require significant efforts to rework the codebase of the project.

The project is named after a superhero Pie Man appeared in the Simpsons' episode [Simple Simpson](https://en.wikipedia.org/wiki/Simple_Simpson).

Pieman is a core component of [CusDeb](https://cusdeb.com).

## Features

* The images can be based on [Alpine](https://alpinelinux.org) and Debian-based distributions such as [Devuan](https://devuan.org), [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) and [Ubuntu](https://ubuntu.com/).
* 64-bit images based on Ubuntu.
* OTA updates via [Mender](https://mender.io/).

## Table of Contents

- [Getting Started](#getting-started)
  * [Dependencies](#dependencies)
    + [Mandatary](#mandatary)
    + [Optional](#optional)
  * [Supported platforms](#supported-platforms)
  * [Installation](#installation)
    + [Docker](#docker)
    + [Manual](#manual)
- [Documentation](#documentation)
  * [Parameters](#parameters)
    + [General](#general)
    + [Networking](#networking)
    + [Package manager](#package-manager)
    + [Users](#users)
    + [Image](#image)
    + [Pieman-specific](#pieman-specific)
    + [Extra](#extra)
- [Running images in emulator](#running-images-in-emulator)
- [Daily image builds](#daily-image-builds)
- [Authors](#authors)
- [Licensing](#licensing)
- [Contribute](#contribute)

## Getting Started

### Dependencies

#### Mandatary

* dosfstools
* dpkg
* GNU Parted
* GnuPG
* mkpasswd
* pandoc
* Python (3.5 or higher)
* PyYAML
* rsync
* Setuptools
* uuidgen
* User mode emulation binaries such as `/usr/bin/qemu-arm-static` and `/usr/bin/qemu-aarch64-static`
* wget

Here are the commands to install the mandatory dependencies
* on Debian or Ubuntu
  ```
  $ sudo apt-get install dosfstools gnupg pandoc parted python3-pip python3-setuptools python3-yaml qemu-user-static rsync uuid-runtime wget whois
  ```
* on Fedora
  ```
  $ sudo dnf install dosfstools dpkg expect gpg pandoc parted python3-pip python3-PyYAML python3-setuptools qemu-user-static rsync wget
  ```

#### Optional

* To enable `COMPRESS_WITH_BZIP2` and `COMPRESS_WITH_XZ`:
  * bzip2
  * xz
* To enable [Mender](https://mender.io) support:
  * Development libraries and header files related to C standard library (make sure the package, which is going to be installed to satisfy the dependency, includes `/usr/include/sys/types.h`)
  * C programming language compiler
  * Go programming language compiler
  * bc
  * dtc
  * make

Here are the commands to install the optional dependencies
* on Debian or Ubuntu
  ```
  sudo apt-get install xz-utils bzip2 bc gcc device-tree-compiler golang make libc6-dev-i386
  ```
* on Fedora
  ```
  sudo dnf install xz bzip2 bc gcc dtc golang make
  ```

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
$ curl -O https://raw.githubusercontent.com/tolstoyevsky/pieman/master/docker-pieman.sh
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

Then, install the Pieman [mandatory dependencies](#mandatary).

Finally, install the required utilities and modules written in Python.

```
$ sudo pip3 install pieman
```

##### Usage

Go to the project directory and execute the following command to create an image based on Raspbian Stretch for Raspberry Pi 3:

```
$ sudo ./pieman.sh
```

To create an image based on Ubuntu Xenial for Raspberry Pi 2 with [htop](https://packages.debian.org/stretch/htop) and [mc](https://packages.debian.org/stretch/mc) pre-installed run

```
$ sudo env DEVICE=rpi-2-b OS=ubuntu-xenial-armhf INCLUDES=htop,mc ./pieman.sh
```

The built image will be located in the `build` directory. By the way, you can specify the name of your project via the `PROJECT_NAME` environment variable. You can find details on `DEVICE`, `INCLUDES`, `OS`, `PROJECT_NAME` and other environment variables (called parameters) which help customizing images in the Documentation section.

## Documentation

|                                                                                             | Alpine 3.9     | Debian 10 «Buster»    | Devuan 1 «Jessie»     | Raspbian 9 «Stretch»  | Ubuntu 16.04 «Xenial Xerus» | Ubuntu 18.04 «Bionic Beaver» |
|---------------------------------------------------------------------------------------------|:--------------:|:---------------------:|:---------------------:|:---------------------:|:---------------------------:|:----------------------------:|
| Orange Pi [PC Plus](http://orangepi.org/orangepipcplus/)                                    |                | 32bit                 |                       |                       |                             |                              |
| Raspberry Pi [Model B and B+](https://www.raspberrypi.org/products/raspberry-pi-1-model-b/) |                |                       |                       | 32bit                 |                             |                              |
| Raspberry Pi [2 Model B](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/)      | 32bit          |                       | 32bit                 | 32bit                 | 32bit                       | 32bit                        |
| Raspberry Pi [3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)      | 32bit          |                       | 32bit                 | 32bit                 |                             | 32bit, 64bit                 |
| Raspberry Pi [Zero](https://www.raspberrypi.org/products/raspberry-pi-zero/)                |                |                       |                       | 32bit                 |                             |                              |

The operating system of the target image is specified via the `OS` environment variable. The next table maps full names of the supported operating systems to their short name intended for using as values of `OS`.

| Full name                                                                                                            | Short name             |
|----------------------------------------------------------------------------------------------------------------------|------------------------|
| Alpine [3.9](https://alpinelinux.org/posts/Alpine-3.9.0-released.html) (32-bit)                                      | alpine-3.9-armhf       |
| Debian 10 «[Buster](https://debian.org/releases/buster/)» (32-bit)                                                   | debian-buster-armhf    |
| Devuan 1 «[Jessie](https://lists.dyne.org/lurker/message/20170525.180739.f86cd310.en.html#devuan-announce)» (32-bit) | devuan-jessie-armhf    |
| Raspbian 9 «[Stretch](https://raspberrypi.org/blog/raspbian-stretch/)» (32-bit)                                      | raspbian-stretch-armhf |
| Ubuntu 16.04 «[Xenial Xerus](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes)» (32-bit)                             | ubuntu-xenial-armhf    |
| Ubuntu 18.04 «[Bionic Beaver](https://wiki.ubuntu.com/BionicBeaver/ReleaseNotes)» (32-bit)                           | ubuntu-bionic-armhf    |
| Ubuntu 18.04 «[Bionic Beaver](https://wiki.ubuntu.com/BionicBeaver/ReleaseNotes)» (64-bit)                           | ubuntu-bionic-arm64    |

The device the target image is created for is specified via the `DEVICE` environment variable. The next table maps full names of the supported devices to their short name intended for using as values of `DEVICE`.

| Full name                   | Short name  |
|-----------------------------|-------------|
| Orange Pi PC Plus           | opi-pc-plus |
| Raspberry Pi Model B and B+ | rpi-b       |
| Raspberry Pi 2 Model B      | rpi-2-b     |
| Raspberry Pi 3 Model B      | rpi-3-b     |
| Raspberry Pi Zero           | rpi-zero    |

### Parameters

#### General

##### OS="raspbian-stretch-armhf"

Specifies the operating system to be used as a base for the target image. You can find all the possible values for the parameter in the table above (see the "Short name" column).

##### DEVICE="rpi-3-b"

Specifies the device the image is going to be run on. You can find all the possible values for the parameter in the table above (see the "Short name" column).

##### BASE_DIR=""

Specifies the chroot environment to be used instead of creating a new one.

Note, that the parameter conflicts with `CREATE_ONLY_CHROOT`.

##### PROJECT_NAME="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

Each image is built in in the context of some project. The parameter allows specifying the project name. By default, the name is a randomly generated UUID 32-character string.

##### BUILD_DIR="build"

Specifies the projects location. By default, the directory named `build` is created in the current directory during the build process with ownership specified via `IMAGE_OWNERSHIP`.

##### CREATE_ONLY_CHROOT=false

Restricts Pieman to only creating a chroot environment based on the operating system specified via `OS`. The chroot environment is stored in `build/${PROJECT_NAME}/chroot` and can be used immediately or later to reduce the time of building images. See `BASE_DIR`.

##### LOCALE="en_US.UTF-8"

Specifies the locale.

##### PIEMAN_DIR="$(pwd)"

Specifies the directory into which Pieman is installed.

##### PREPARE_ONLY_TOOLSET=false

Restricts Pieman to only preparing or upgrading the toolset which is located in the directory specified via `TOOLSET_DIR`.

##### TIME_ZONE="Etc/UTC"

Specifies the time zone of the system.

##### TOOLSET_DIR="${PIEMAN_DIR}/toolset"

Specifies the directory which contains the tools necessary for creating chroot environments based on Alpine Linux and different Debian-based distributions. The toolset consists of [debootstrap](https://wiki.debian.org/Debootstrap) and [apk.static](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management).

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

Specifies whether to install packages without checking their signatures.

##### ENABLE_COMMUNITY=false

This is an Alpine-specific parameter. It enables the [community](https://wiki.alpinelinux.org/wiki/Enable_Community_Repository) repository.

##### ENABLE_NONFREE=false

This is a Debian-specific parameter. It enables the [non-free and contrib](https://wiki.debian.org/SourcesList#Component) sections in `/etc/apt/sources.list`. By default, only the main section is used. Sections are also called components or areas.

##### ENABLE_UNATTENDED_INSTALLATION=false

Specifies whether to install packages without prompting the user to answer any questions.

##### ENABLE_UNIVERSE=false

This is an Ubuntu-specific parameter. It enables the [universe](https://help.ubuntu.com/community/Repositories/Ubuntu#The_Four_Main_Repositories) section in `/etc/apt/sources.list`. By default, only the main section is used.

##### INCLUDES=""

A comma-separated list of the packages to be installed on the system specified via `OS`.

---

#### Users

##### ENABLE_SUDO=true

Specifies whether to install `sudo`. If `ENABLE_USER` is set to `true`, Pieman adds the user `USER_NAME` to `/etc/sudoers`.

##### ENABLE_USER=true

Specifies whether to create a non-root user `USER_NAME` with the password `USER_PASSWORD`.

##### PASSWORD="secret"

Specifies the root password. It's **HIGHLY RECOMMENDED** to change the default root password.

If `PASSWORD` equals to `-`, Pieman will prompt for a password, and read it without echoing to screen.

##### SUDO_REQUIRE_PASSWORD=true

Tells `sudo` whether it should prompt for the password.

It's necessary to disable the password prompts if you want to manage your device via, for example, [SSH Button](https://play.google.com/store/apps/details?id=com.pd7l.sshbutton).

##### USER_NAME="cusdeb"

Specifies a non-root user name. It's ignored if `ENABLE_USER` is set to `false`.

##### USER_PASSWORD="secret"

Specifies a non-root user password. It's ignored if `ENABLE_USER` is set to `false`. It's **HIGHLY RECOMMENDED** to change the default user password.

If `USER_PASSWORD` equals to `-`, Pieman will prompt for a password, and read it without echoing to screen.

---

### Image

##### COMPRESS_WITH_BZIP2=false

Compresses the resulting image using `bzip2`.

Note, that the parameter conflicts with `COMPRESS_WITH_GZIP` and `COMPRESS_WITH_XZ`.

##### COMPRESS_WITH_GZIP=false

Compresses the resulting image using `gzip`.

Note, that the parameter conflicts with `COMPRESS_WITH_BZIP2` and `COMPRESS_WITH_XZ`.

##### COMPRESS_WITH_XZ=false

Compresses the resulting image using `xz`.

Note, that the parameter conflicts with `COMPRESS_WITH_BZIP2` and `COMPRESS_WITH_GZIP`.

##### IMAGE_OWNERSHIP="$(id -u "$(stat -c "%U" "$0")"):$(id -g "$(stat -c "%G" "$0")")"

Specifies the ownership of the target image (see `PROJECT_NAME`) and project directory (see `BUILD_DIR`). By default, the ownership is borrowed from `pieman.sh` which, as a rule, belongs to a regular user.

Note, that the parameter must follow the format "uid:gid" where `uid` and `gid` are numbers.

##### IMAGE_ROOTFS_SIZE=0 #####

Specifies the rootfs partition size in megabytes. Beware! Build will fail if rootfs doesn't fit into that size. If the parameter is equal to 0, the rootfs size will be calculated automatically.

---

#### Pieman-specific

##### PYTHON="$(which python3)"

Specifies the Python 3 interpreter to be used when calling the Pieman-specific utilities.

#### Extra

##### CREATE_ONLY_MENDER_ARTIFACT=false

Restricts Pieman to only creating an artifact (a file with the `.mender` extension) which can later be uploaded to [hosted.mender.io](https://hosted.mender.io) to provide for OTA updates.

Note, that the parameter conflicts with `CREATE_ONLY_CHROOT` and `ENABLE_MENDER`.

##### ENABLE_BSC_CHANNEL=false

Specifies whether to run the build status codes server (also known as bscd). If the parameter is set to `true`, Pieman will check the connection to the Redis server (specified via `REDIS_HOST` and `REDIS_PORT`) and, in case there is no problem with that, it will be pushing the build status codes to the channel named `bscd-${PROJECT_NAME}`.

See the documentation page devoted to the [build status codes server and client](doc/bsc_server_and_client.md) for the details.

##### ENABLE_MENDER=false

Specifies whether to install the Mender client to provide for OTA updates.

Note that the OTA updates support is currently limited to 32-bit Raspbian for Raspberry Pi 3 Model B.

##### MENDER_ARTIFACT_NAME="release-1_1.7.0"

The name of an image or update (called [artifact](https://docs.mender.io/1.7/architecture/mender-artifacts)) that will be built if either `ENABLE_MENDER` or `CREATE_ONLY_MENDER_ARTIFACT` is specified. Note that different updates must have different names.

##### MENDER_DATA_SIZE=128

Specifies the size in megabytes of the data partition.

The parameter is used only when `ENABLE_MENDER` is set to `true`.

##### MENDER_INVENTORY_POLL_INTERVAL=86400

Specifies the frequency (in seconds) for periodically sending inventory data. Inventory data is always sent after each boot of the device, and after a new update has been correctly applied and committed by the device in addition to this periodic interval. Default value: 86400 seconds (one day).

##### MENDER_RETRY_POLL_INTERVAL=300

Specifies the number of seconds to wait between each attempt to download an update file. Note that the client may attempt more often initially to enable rapid upgrades, but will gradually fall back to this value if the server is busy. See `MENDER_INVENTORY_POLL_INTERVAL`.

##### MENDER_TENANT_TOKEN=""

Specifies a token which identifies which tenant a device belongs to. It requires an account on [hosted.mender.io](https://hosted.mender.io).

The parameter is used only when `ENABLE_MENDER` is set to `true`.

##### MENDER_SERVER_URL="https://hosted.mender.io"

Specifies the server for the client to connect to.

##### MENDER_UPDATE_POLL_INTERVAL=1800

Specifies the frequency (in seconds) the client will send an update check request to the server. Default value: 1800 seconds (30 minutes).

##### REDIS_HOST="127.0.0.1"

Specifies the Redis server host used by the build status codes server (see `ENABLE_BSC_CHANNEL`). 

##### REDIS_PORT=6379

Specifies the Redis server port used by the build status codes server (see `ENABLE_BSC_CHANNEL`). 

## Running images in emulator

It's possible to run the images built by Pieman in QEMU. The nearby project [MMB](https://github.com/tolstoyevsky/mmb) simplifies the process. The project is the set of Dockerfiles and assets for building Docker images with different services. Now [QEMU](https://github.com/tolstoyevsky/mmb/tree/master/qemu), which is one of the services, helps running the images based on Ubuntu 18.04 «Bionic Beaver» (64-bit) for Raspberry Pi 3.

## Daily image builds

You can find the images of all supported operating systems for all supported devices [here](https://cusdeb.com/images-built-by-pieman). Login username is `cusdeb`, password is `secret`.

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
