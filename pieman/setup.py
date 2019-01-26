""" Script for building the Pieman package. """

from setuptools import setup

try:
    import pypandoc
    LONG_DESCRIPTION = pypandoc.convert('README.md', 'rst')
except ImportError:
    LONG_DESCRIPTION = ('Utilities written in Python which are used by '
                        'Pieman, script for creating custom OS images for '
                        'single-board computers.')


setup(name='pieman',
      version='0.6.0',
      description='Pieman package',
      long_description=LONG_DESCRIPTION,
      url='https://github.com/tolstoyevsky/pieman',
      author='Evgeny Golyshev',
      maintainer='Evgeny Golyshev',
      maintainer_email='eugulixes@gmail.com',
      license='https://gnu.org/licenses/gpl-3.0.txt',
      scripts=[
          'bin/apk_tools_version.py',
          'bin/check_mutually_exclusive_params.py',
          'bin/du.py',
          'bin/image_attrs.py',
      ],
      packages=['pieman'],
      install_requires=[
          'PyYAML',
      ])
