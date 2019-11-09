""" Script for building the Pieman package. """

from setuptools import setup

try:
    import pypandoc
    LONG_DESCRIPTION = pypandoc.convert('README.md', 'rst')
except ImportError:
    LONG_DESCRIPTION = ('Utilities written in Python which are used by '
                        'Pieman, script for creating custom OS images for '
                        'single-board computers.')


with open('requirements.txt') as outfile:
    REQUIREMENTS_LIST = outfile.read().splitlines()


setup(name='pieman',
      version='0.13.0',
      description='Pieman package',
      long_description=LONG_DESCRIPTION,
      url='https://github.com/tolstoyevsky/pieman',
      author='Evgeny Golyshev',
      maintainer='Evgeny Golyshev',
      maintainer_email='eugulixes@gmail.com',
      license='https://gnu.org/licenses/gpl-3.0.txt',
      scripts=[
          'bin/apk_tools_version.py',
          'bin/bsc.py',
          'bin/bscd.py',
          'bin/check_mutually_exclusive_params.py',
          'bin/check_redis.py',
          'bin/check_wpa_passphrase.py',
          'bin/depend_on.py',
          'bin/du.py',
          'bin/image_attrs.py',
          'bin/render.py',
      ],
      packages=['pieman'],
      include_package_data=True,
      data_files=[
          ('', ['requirements.txt']),
          ('pieman', ['pieman/build_status_codes']),
      ],
      install_requires=REQUIREMENTS_LIST)
