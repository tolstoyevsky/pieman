[![pypi](https://badge.fury.io/py/pieman.svg)](https://badge.fury.io/py/pieman)

# pieman

The package contains the utilities which are used by [Pieman](https://github.com/tolstoyevsky/pieman), script for creating custom OS images for single-board computers. The utilities are:

* `du.py`: provides the disk usage of the specified directory. It was developed primarily for estimating chroot environments disk usage. In some cases the utility provides more accurate result than `du` from GNU [coreutils](https://gnu.org/software/coreutils/).
* `image_attrs.py`: allows getting image attributes which are stored in the `pieman.yml` files. The utility is more high-level tool than [PyYAML](https://pyyaml.org) because it's aware of the `pieman.yml` specifics.

## Installation

Using `pip`:

```pip install pieman```

Manually:

```python3 setup.py build```
