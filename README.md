[![Linter and Tests](https://github.com/tolstoyevsky/pieman/actions/workflows/linter.yml/badge.svg)](https://github.com/tolstoyevsky/pieman/actions/workflows/linter.yml) [![](https://images.microbadger.com/badges/image/cusdeb/pieman.svg)](https://hub.docker.com/r/cusdeb/pieman/) [![](https://images.microbadger.com/badges/commit/cusdeb/pieman.svg)](https://hub.docker.com/r/cusdeb/pieman/)

# Pieman [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&logo=twitter)](https://twitter.com/intent/tweet?text=Create%20a%20custom%20OS%20image%20for%20for%20your%20Raspberry%20Pi&url=https://github.com/tolstoyevsky/pieman&via=CusDeb&hashtags=RaspberryPi,Raspbian,Ubuntu)

<p align="center">
    <img src="/logo/380x400.png" alt="Pieman">
</p>

Pieman is a script for creating custom OS images for single-board computers such as Raspberry Pi and Orange Pi. The authors of Pieman were inspired by the project named [rpi23-gen-image](https://github.com/drtyhlpr/rpi23-gen-image). The main reason why it was decided to create a new project instead of improving the existing one is that rpi23-gen-image is intended for creating images only for Raspberry Pi 2 and 3 based on Debian GNU/Linux. Unfortunately, it doesn't have a way to be extended to support different operating systems and single-board computers. Improving the situation would require significant efforts to rework the codebase of the project.

The project is named after a superhero Pie Man appeared in the Simpsons' episode [Simple Simpson](https://en.wikipedia.org/wiki/Simple_Simpson).

Pieman is a core component of [CusDeb](https://cusdeb.com).

## Features

* The images can be based on [Alpine](https://alpinelinux.org) and Debian-based distributions such as [Kali](https://kali.org), [Raspberry Pi OS](https://raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit) (formerly Raspbian) and [Ubuntu](https://ubuntu.com/).
* 64-bit images based on Ubuntu.
* OTA updates via [Mender](https://mender.io/).

## Table of Contents

- [Supported Devices and OSes](#supported-devices-and-oses)
- [Getting Started](#getting-started)
  * [Dependencies](#dependencies)
    + [Mandatary](#mandatary)
    + [Optional](#optional)
  * [Supported platforms](#supported-platforms)
  * [Installation](#installation)
    + [Docker](#docker)
    + [Manual](#manual)
- [Running tests](#running-tests)
- [Documentation](#documentation)
  * [Parameters](#parameters)
    + [General](#general)
    + [Networking](#networking)
    + [Package manager](#package-manager)
    + [Users](#users)
    + [Image](#image)
    + [Pieman-specific](#pieman-specific)
    + [Extra](#extra)
  * [Storing parameters in .env file](#storing-parameters-in-env-file)
- [Running images in emulator](#running-images-in-emulator)
- [FAQ](#faq)
- [Authors](#authors)
- [Licensing](#licensing)
- [Contribute](#contribute)

## Supported Devices and OSes

|                                                                                                                     | <sub>Alpine 3.12</sub> | <sub>Debian 10 «Buster»</sub> | <sub>Kali Linux Rolling</sub>   |<sub>Raspberry Pi OS 10 «Buster»</sub>  | <sub>Ubuntu 16.04 «Xenial Xerus»</sub> | <sub>Ubuntu 18.04 «Bionic Beaver»</sub> | <sub>Ubuntu 20.04 «Focal Fossa»</sub> |
|---------------------------------------------------------------------------------------------------------------------|:---------------------:|:-----------------------------:|:-------------------------------:|:-------------------------------:|:--------------------------------------:|:---------------------------------------:|:-------------------------------------:|
| <sub>Orange Pi <a href="http://orangepi.org/orangepipcplus/">PC Plus</a></sub>                                      |                       | <sub>32bit</sub>              | <sub>32bit</sub>                |                                 |                                        |                                         |                                       |
| <sub>Orange Pi <a href="http://www.orangepi.org/orangepizero/">Zero</a></sub>                                       |                       | <sub>32bit</sub>              | <sub>32bit</sub>                |                                 |                                        |                                         |                                       |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-1-model-b/">Model B and B+</a></sub>   |                       |                               |                                 | <sub>32bit</sub>                |                                        |                                         |                                       |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-2-model-b/">2 Model B</a></sub>        | <sub>32bit</sub>      |                               |                                 | <sub>32bit</sub>                | <sub>32bit</sub>                       | <sub>32bit</sub>                        |                                       |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-3-model-b/">3 Model B</a></sub>        | <sub>32bit</sub>      |                               |                                 | <sub>32bit</sub>                |                                        | <sub>32bit, 64bit</sub>                 |                                       |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/">3 Model B+</a></sub>  | <sub>32bit</sub>      |                               |                                 |                                 |                                        | <sub>32bit</sub>                        | <sub>32bit</sub>                      |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-4-model-b/">4 Model B</a></sub>        |                       |                               |                                 | <sub>32bit</sub>                |                                        |                                         |                                       |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-zero/">Zero</a></sub>                  |                       |                               |                                 | <sub>32bit</sub>                |                                        |                                         |                                       |
| <sub>Raspberry Pi <a href="https://www.raspberrypi.org/products/raspberry-pi-zero-w/">Zero W</a></sub>              |                       |                               |                                 | <sub>32bit</sub>                |                                        |                                         |                                       |

## Getting Started

### Dependencies

#### Mandatary

* Development tools
  * GNU Bison
  * C programming language compiler
  * Flex
  * Git
  * Make
  * SWIG
* Python
  * Development libraries and header files related to Python 2.7
  * Python 2.7
  * Python 3 (3.5 or higher)
  * Setuptools
* Utils
  * dosfstools
  * dpkg
  * GNU Parted
  * GnuPG
  * mkfs.ext4 
  * rsync
  * User mode emulation binaries such as `/usr/bin/qemu-arm-static` and `/usr/bin/qemu-aarch64-static`
  * xz

Note that installing `qemu-user-static` is not enough in Debian/Ubuntu. You also have to install `binfmt-support`.

Here are the commands to install the mandatory dependencies
* on Debian or Ubuntu
  ```
  $ sudo apt-get install binfmt-support bison dosfstools flex gcc git gnupg make parted python-dev python3-pip python3-setuptools qemu-user-static swig rsync xz-utils
  ```
* on Fedora
  ```
  $ sudo dnf install bison dosfstools dpkg e2fsprogs flex gcc git gpg make parted python2-devel python3-pip python3-setuptools qemu-user-static rsync swig xz
  ```

#### Optional

* To enable `COMPRESS_WITH_BZIP2`: bzip2
* To enable [Mender](https://mender.io) support:
  * Development libraries and header files related to C standard library (make sure the package, which is going to be installed to satisfy the dependency, includes `/usr/include/sys/types.h`)
  * Go programming language compiler
  * bc
  * dtc

Here are the commands to install the optional dependencies
* on Debian or Ubuntu
  ```
  sudo apt-get install bzip2 bc gcc device-tree-compiler golang libc6-dev-i386
  ```
* on Fedora
  ```
  sudo dnf install bc bzip2 dtc golang
  ```

### Supported platforms

Theoretically, Pieman can be run on any GNU/Linux, however, it was very carefully tested only on:
* Debian 9 «Stretch»
* Fedora 29
* Ubuntu 16.04 «Xenial Xerus»
* macOS 10.13 «High Sierra» (running Pieman in the official Docker container)

### Installation

#### Docker

First, make sure that the following requirements are satisfied:
* Bash 4 or higher;
* `qemu-user-static` and `binfmt-support` on Debian or Ubuntu;
* `qemu-user-static` on Fedora.

Next, get the latest Pieman Docker image from Docker Hub.

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

Finally, go to the next section to know how to use the script.

##### Usage

Simply run `docker-pieman.sh` to create an image based on Raspberry Pi OS Buster for Raspberry Pi 3.

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

Finally, install the required utilities and modules written in Python either globally

```
$ sudo pip3 install pieman
```

or to the virtual environment (recommended)

```
$ virtualenv -ppython3 venv
$ ./venv/bin/pip3 install pieman
```

Note that the virtual environment must be called `venv` and located at the root of the Pieman source tree.

##### Usage

Go to the project directory and execute the following command to create an image based on Raspberry Pi OS Buster for Raspberry Pi 3:

```
$ sudo ./pieman.sh
```

To create an image based on Ubuntu Xenial for Raspberry Pi 2 with [htop](https://packages.debian.org/stretch/htop) and [mc](https://packages.debian.org/stretch/mc) pre-installed run

```
$ sudo env DEVICE=rpi-2-b OS=ubuntu-xenial-armhf INCLUDES=htop,mc ./pieman.sh
```

The built image will be located in the `build` directory. By the way, you can specify the name of your project via the `PROJECT_NAME` environment variable. You can find details on `DEVICE`, `INCLUDES`, `OS`, `PROJECT_NAME` and other environment variables (called parameters) which help customizing images in the Documentation section.

## Running tests

The Pieman tests are divided into two parts: the tests for the package (which contains the utilities written in Python) and the tests for the Pieman script (written in Bash).

To run the tests for the package, create a virtual environment, activate it and install the Pieman requirements to it (suppose you are in the directory which contains the Pieman source code directory).

```
$ virtualenv -p python3 pieman-env
$ source ./pieman-env/bin/activate
$ pip install pieman
```

Then run the tests from the Pieman source code directory in the following way:

```
$ ./pieman/test/runtest.py
```

To run the tests for the Pieman script, you will need both the above-mentioned virtual environment (because the Pieman script tests depends on the package tests) and [shUnit2](https://github.com/kward/shunit2). Install shUnit2 executing `sudo apt-get install shunit2` on Debian/Ubuntu or `sudo dnf install shunit2` on Fedora. Then, go to the `test` directory and run the tests in the following way:

```
$ ./test/test_essentials.sh
$ ./test/test_functions.sh
```

## Documentation

The operating system of the target image is specified via the `OS` environment variable. The next table maps full names of the supported operating systems to their short name intended for using as values of `OS`.

| Full name                                                                                                            | Short name             |
|----------------------------------------------------------------------------------------------------------------------|------------------------|
| Alpine [3.12](https://alpinelinux.org/posts/Alpine-3.12.0-released.html) (32-bit)                                    | alpine-3.12-armhf      |
| Debian 10 «[Buster](https://debian.org/releases/buster/)» (32-bit)                                                   | debian-buster-armhf    |
| Kali Linux Rolling (32-bit)                                                                                          | kali-rolling-armhf     |
| Raspberry Pi OS 10 «[Buster](https://raspberrypi.org/blog/buster-the-new-version-of-raspbian/)» (32-bit)             | raspberrypios-buster-armhf  |
| Ubuntu 16.04 «[Xenial Xerus](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes)» (32-bit)                             | ubuntu-xenial-armhf    |
| Ubuntu 18.04 «[Bionic Beaver](https://wiki.ubuntu.com/BionicBeaver/ReleaseNotes)» (32-bit)                           | ubuntu-bionic-armhf    |
| Ubuntu 18.04 «[Bionic Beaver](https://wiki.ubuntu.com/BionicBeaver/ReleaseNotes)» (64-bit)                           | ubuntu-bionic-arm64    |
| Ubuntu 20.04 «[Focal Fossa](https://wiki.ubuntu.com/FocalFossa/ReleaseNotes)» (32-bit)                               | ubuntu-focal-armhf     |

The device the target image is created for is specified via the `DEVICE` environment variable. The next table maps full names of the supported devices to their short name intended for using as values of `DEVICE`.

| Full name                   | Short name  |
|-----------------------------|-------------|
| Orange Pi PC Plus           | opi-pc-plus |
| Orange Pi Zero              | opi-zero    |
| Raspberry Pi Model B and B+ | rpi-b       |
| Raspberry Pi 2 Model B      | rpi-2-b     |
| Raspberry Pi 3 Model B      | rpi-3-b     |
| Raspberry Pi 3 Model B+     | rpi-3-b-plus|
| Raspberry Pi 4 Model B      | rpi-4-b     |
| Raspberry Pi Zero           | rpi-zero    |
| Raspberry Pi Zero W         | rpi-zero-w  |

### Parameters

#### General

##### OS="raspberrypios-buster-armhf"

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

##### TOOLSET_CODENAME="v4-amy"

Specifies the toolset codename. The parameter allows users and developers to switch between different toolsets. Each codename is connected to its directory in `${TOOLSET_DIR}` which, in turn, contains the target toolset. When a codename is passed via `${TOOLSET_CODENAME}` but there is no such directory in `${TOOLSET_DIR}`, the process of creating of the directory and installing the toolset into it will be initiated.

Note that the default codename belongs to the latest toolset which supports all the Pieman features, so if you don't have any particular reason why you should change the codename, it's recommended to use the default one. However, if you decide to change the default codename, you should know how to later distinguish the official toolsets from your own ones. The official toolsets have the following naming convention: `v{n}-{name}` where `{n}` is an order number and `{name}` is a character name from the Futurama/Simpsons universe.

##### TOOLSET_DIR="${PIEMAN_DIR}/toolset"

Specifies the directory which contains the tools necessary for creating chroot environments based on Alpine Linux and different Debian-based distributions. The toolset consists of [debootstrap](https://wiki.debian.org/Debootstrap) and [apk.static](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management).

##### XFCE4="false"

Specifies whether to install xfce4 with lxdm. Available only on Ubuntu 18.04 Bionic Beaver 32-bit or 64-bit.

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

##### ENABLE_WIRELESS=false

Enables built-in WiFi (only for Raspberry Pi OS Buster on Raspberry Pi 3 and Raspberry Pi Zero W so far).

##### HOST_NAME="pieman-${DEVICE}"

Specifies the hostname of a device.

##### WPA_SSID=""

Specifies the name of the wireless access point. The access point is considered as **private** or **public** depending on whether `WPA_PSK` (see below) is specified or not.

Note that the parameter depends on `ENABLE_WIRELESS` (see above).

##### WPA_PSK=""

Specifies the passphrase for connecting to the wireless access point, specified via `WPA_SSID` (see above).

Leave `WPA_PSK` empty if the access point is public.

Note that the parameter depends on `ENABLE_WIRELESS` and `WPA_SSID` (see above).

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

##### PYTHON="python3"

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

Note that the OTA updates support is currently limited to 32-bit Raspberry Pi OS for Raspberry Pi 3 Model B.

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

### Storing parameters in .env file

You can also specify the parameters in the `.env` file. In this case they will have the higher priority than the parameters provided via the command line.

## Running images in emulator

It's possible to run the images built by Pieman in QEMU. The nearby project [MMB](https://github.com/tolstoyevsky/mmb) simplifies the process. The project is the set of Dockerfiles and assets for building Docker images with different services. Now [QEMU](https://github.com/tolstoyevsky/mmb/tree/master/qemu), which is one of the services, helps running the images based on Ubuntu 18.04 «Bionic Beaver» (64-bit) for Raspberry Pi 3.

## FAQ

### DNS resolving is broken in Kali Linux

According to the [Kali Linux Policies](https://kali.training/topic/kali-linux-policies/), network services are disabled by default. To waken the DNS resolving from its sleep, run the following commands

```
sudo systemctl enable resolvconf
sudo systemctl start resolvconf
```

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
