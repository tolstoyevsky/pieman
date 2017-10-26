<p align="center">
    <img src="/logo/380x400.png" alt="Pieman">
</p>

Pieman is a script for creating custom OS images for single-board computers such as Raspberry Pi. The images are based on Debian GNU/Linux and its derivatives at this time. The authors of Pieman were inspired by the project named [rpi23-gen-image](https://github.com/drtyhlpr/rpi23-gen-image). The main reason why it was decided to create a new project instead of improving the existing one is that rpi23-gen-image is intended for creating images only for Raspberry Pi 2 and 3 based on Debian GNU/Linux. Unfortunately, it doesn't have a way to be extended to support different operating systems and single-board computers. Improving the situation would require significant efforts to rework the codebase of the project.

## Getting Started

To install Pieman use Docker. The documentation on how to install the script from source code is on its way.

```
docker pull cusdeb/pieman
```

To create an image based on Raspbian Stretch for Raspberry Pi 3 run

```
docker run pieman > raspbian_rpi3.img
```

To create an image based on Ubuntu Xenial for Raspberry Pi 2 with [htop](https://packages.debian.org/stretch/htop) and [mc](https://packages.debian.org/stretch/mc) pre-installed run

```
docker run -e DEVICE=rpi-2-b INCLUDES=htop,mc OS=debian-stretch-armhf > ubuntu_rpi2.img
```

You can find details on `DEVICE`, `INCLUDES`, `OS` and other environment variables (called parameters) which help customizing images in the Documentation section.

## Documentation

|                                                                                             | Raspbian 9 «Stretch»  | Ubuntu 16.04 «Xenial Xerus» | Ubuntu 17.10 «Artful Aardvark» |
|---------------------------------------------------------------------------------------------|:---------------------:|:---------------------------:|:------------------------------:|
| Raspberry Pi [Model B and B+](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/) | 32bit                 |                             |                                |
| Raspberry Pi [2 Model B](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/)      | 32bit                 | 32bit                       |                                |
| Raspberry Pi [3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)      | 32bit                 |                             | 64bit                          |
| Raspberry Pi [Zero](https://www.raspberrypi.org/products/raspberry-pi-zero/)                | 32bit                 |                             |                                |

The operating system of the target image is specified via the `OS` environment variable. The next table maps full names of the supported operating systems to their short name intended for using as values of `OS`.

| Full name                               | Short name             |
|-----------------------------------------|------------------------|
| Raspbian 9 «[Stretch](https://raspberrypi.org/blog/raspbian-stretch/)» (32-bit)           | raspbian-stretch-armhf |
| Ubuntu 16.04 «[Xenial Xerus](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes)» (32-bit)    | ubuntu-xenial-armhf    |
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

---

#### Package manager

##### ENABLE_NONFREE=false

This is a Debian-specific parameter. It enables the [non-free and contrib](https://wiki.debian.org/SourcesList#Component) sections in `/etc/apt/sources.list`. By default, only the main section is used. Sections are also called components or areas.

##### ENABLE_UNIVERSE=false

This is an Ubuntu-specific parameter. It enables the [universe](https://help.ubuntu.com/community/Repositories/Ubuntu#The_Four_Main_Repositories) section in `/etc/apt/sources.list`. By default, only the main section is used.

##### INCLUDES=""

A comma-separated list of the packages to be installed on the system specified via `OS`.

---

#### Users

##### PASSWORD="secret"

Allows specifying the root password. It's **HIGHLY RECOMMENDED** to change the default root password.

---

#### Pieman-specific

##### PYTHON="`which python3`"

Allows specifying the Python 3 interpreter to be used when calling the Pieman-specific utilities. 

## Authors

See [AUTHORS](AUTHORS.md).

## Licensing

Pieman is available under the [GNU General Public License version 3](LICENSE).

Pieman borrows some pieces of code from rpi23-gen-image which are available under the [GNU General Public License version 2](https://gnu.org/licenses/old-licenses/gpl-2.0.txt).
