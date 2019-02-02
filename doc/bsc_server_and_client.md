# Build status codes server and client

Pieman, as a server-side software, is capable of informing in real time the clients about build status codes allowing them, in turn, to show the users the current progress of building images.

Using the `ENABLE_BSC_CHANNEL` parameter set to `true` it is possible to run the build status codes server (also known as bscd). The server will require the Redis server (specified via `REDIS_HOST` and `REDIS_PORT`) to act as a broker. When Pieman sees that Redis is available, Pieman will be pushing the build status codes via the built-in client intended for communicating with the server. At the same time, any client-side software may subscribe to the channel named `bscd-${PROJECT_NAME}` and receive the build status codes in real time.

## Build status codes

Here is the full list of the build status codes with their description.
* 10 – done with preparing the chroot environment. Either `debootstrap` or `apk.static` is invoked at this stage (of course if only `CREATE_ONLY_CHROOT` is not set to `true`).
* 20 – done with setting up locale.
* 21 – done with setting up time zone.
* 30 – done with updating indexes (`apt-get update` in case of Debian-based distribution and `apk update` in case of Alpine Linux). 
* 31 – done with installing the packages specified by the user (via the `INCLUDES` parameter).
* 32 – done with upgrading the operating system the target image is based on.
* 33 – done with installing the kernel.
* 40 – done with preparing the boot partition.
* 50 – done with networking.
* 60 – done with users.
* 70 – done with cleaning up (removing the cached packages, indexes, etc).
* 80 – done with creating the target image.
* 81 – done with formatting partitions.
* 82 – done with syncing the chroot environment directory located on the host with the rootfs partition.
* 1000 – success (if everything was fine).
* 1001 – fail (if something went wrong).

## See also

* The [pieman/pieman/build_status_codes](/pieman/pieman/build_status_codes) module containing the list of the build status codes which is shared by both the server and client.
* The [INCLUDES](https://github.com/tolstoyevsky/pieman#includes) parameter.
* The [PROJECT_NAME](https://github.com/tolstoyevsky/pieman#project_namexxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx) parameter.
* The [Extra](https://github.com/tolstoyevsky/pieman#extra) section of the Documentation for the details related to `ENABLE_BSC_CHANNEL`, `REDIS_HOST` and `REDIS_PORT`.
