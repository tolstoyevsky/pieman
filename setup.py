from setuptools import setup


setup(name='pieman',
      version='0.1',
      description=('Utilities written in Python which are used by Pieman, '
                   'script for creating custom OS images for single-board '
                   'computers/'),
      url='https://github.com/tolstoyevsky/pieman',
      author='Evgeny Golyshev',
      maintainer='Evgeny Golyshev',
      maintainer_email='eugulixes@gmail.com',
      license='https://gnu.org/licenses/gpl-3.0.txt',
      scripts=['bin/image_attrs.py'],
      packages=['pieman'],
      install_requires=[
          'PyYAML',
      ])
