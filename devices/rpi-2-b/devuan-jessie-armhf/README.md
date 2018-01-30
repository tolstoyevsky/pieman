Devuan is a systemd-free fork of Debian GNU/Linux which is developed by [Veteran Unix Admins](https://vua.tidyhq.com/). `rpi-2-b/devuan-jessie-armhf` allows building custom 32-bit Devuan [Jessie](https://lists.dyne.org/lurker/message/20170525.180739.f86cd310.en.html#devuan-announce) images for [Raspberry Pi 2 B](https://raspberrypi.org/products/raspberry-pi-2-model-b/) and [Raspberry Pi 3 B](https://raspberrypi.org/products/raspberry-pi-3-model-b/). Note that both Debian Jessie and Devuan Jessie are based on [Linux 3.16](https://lkml.org/lkml/2014/8/3/82) which lacks support for Raspberry Pi. So, Pieman suggests using [Linux 4.9](https://github.com/raspberrypi/linux/tree/rpi-4.9.y) from [Raspbian Jessie](https://raspberrypi.org/blog/raspbian-jessie-is-here/).

## What's in the distribution?

<table>
  <tr>
    <td>Package</td>
    <td>Version</td>
  </tr>
  <tr>
    <td colspan="2"><b>Essential components</b></td>
  </tr>
  <tr>
    <td>Linux kernel</td>
    <td>4.9</td>
  </tr>
  <tr>
    <td>glibc</td>
    <td>2.19</td>
  </tr>
  <tr>
    <td>GCC</td>
    <td>4.9.2</td>
  </tr>
  <tr>
    <td>SysVinit</td>
    <td>2.88</td>
  </tr>
  <tr>
    <td colspan="2"><b>Development tools</b></td>
  </tr>
  <tr>
    <td>Go</td>
    <td>1.3.3</td>
  </tr>
  <tr>
    <td>PHP</td>
    <td>5.6.33</td>
  </tr>
  <tr>
    <td>Python</td>
    <td>3.4.2</td>
  </tr>
  <tr>
    <td>Ruby</td>
    <td>2.1.5</td>
  </tr>
  <tr>
    <td colspan="2"><b>Server software</b></td>
  </tr>
  <tr>
    <td>Apache HTTP Server</td>
    <td>2.4.10</td>
  </tr>
  <tr>
    <td>Nginx</td>
    <td>1.6.2</td>
  </tr>
  <tr>
    <td>PostgreSQL</td>
    <td>9.4</td>
  </tr>
  <tr>
    <td>MySQL</td>
    <td>5.5.59</td>
  </tr>
</table>
