[![pypi](https://badge.fury.io/py/pieman.svg)](https://badge.fury.io/py/pieman)

# pieman

The package contains the utilities which are used by [Pieman](https://github.com/tolstoyevsky/pieman), script for creating custom OS images for single-board computers. The utilities are:

* `check_wpa_passphrase.py`: checks if WPA passphrases are valid. A passphrase is considered as valid when 1) it's between 8 and 63 characters and 2) it doesn't contain any special characters. These two simple checks were borrowed from the original wpa_supplicant codebase and rewritten in Python (see `wpa_supplicant/wpa_passphrase.c`).
* `depend_on.py`: sometimes one environment variable (A) can't be specified without another one (B), so this utility helps Pieman explicitly say that A depends on B and check if B is set to true (if bool) or simply specified (in other cases) when A is set to true (if bool) or simply specified (in other cases).
* `du.py`: provides the disk usage of the specified directory. It was developed primarily for estimating chroot environments disk usage. In some cases the utility provides more accurate result than `du` from GNU [coreutils](https://gnu.org/software/coreutils/).
* `image_attrs.py`: allows getting image attributes which are stored in the `pieman.yml` files. The utility is more high-level tool than [PyYAML](https://pyyaml.org) because it's aware of the `pieman.yml` specifics.
* `render.py`: renders config templates (which are [Jinja2](https://jinja.palletsprojects.com) templates under the hood).
* `wget.py`: very limited GNU [Wget](https://www.gnu.org/software/wget/) alternative.

## Installation

```sudo pip3 install pieman```

