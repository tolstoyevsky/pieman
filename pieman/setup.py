from setuptools import setup

try:
    import pypandoc
    long_description = pypandoc.convert('README.md', 'rst')
except ImportError:
    long_description = ('Utilities written in Python which are used by '
                        'Pieman, script for creating custom OS images for '
                        'single-board computers.')


setup(name='pieman',
      version='0.4.0',
      description='Pieman package',
      long_description=long_description,
      url='https://github.com/tolstoyevsky/pieman',
      author='Evgeny Golyshev',
      maintainer='Evgeny Golyshev',
      maintainer_email='eugulixes@gmail.com',
      license='https://gnu.org/licenses/gpl-3.0.txt',
      scripts=[
          'bin/apk-tools-version.py',
          'bin/du.py',
          'bin/image_attrs.py',
      ],
      packages=['pieman'],
      install_requires=[
          'PyYAML',
      ])
