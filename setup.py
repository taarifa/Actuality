from setuptools import setup

dep_links = ['git+https://github.com/taarifa/TaarifaAPI#egg=TaarifaAPI-dev']
setup(name='Actuality',
      version='dev',
      description="Real data makes a real difference",
      long_description=open('README.rst').read(),
      author='The Taarifa Organisation',
      author_email='taarifadev@gmail.com',
      url='http://actuality.taarifa.org',
      download_url='https://github.com/taarifa/Actuality',
      classifiers=[
          'Development Status :: 3 - Alpha',
          'Intended Audience :: Developers',
          'Intended Audience :: Science/Research',
          'License :: OSI Approved :: BSD License',
          'Operating System :: OS Independent',
          'Programming Language :: Python :: 2',
          'Programming Language :: Python :: 2.6',
          'Programming Language :: Python :: 2.7',
      ],
      packages=['actuality'],
      include_package_data=True,
      zip_safe=False,
      install_requires=['TaarifaAPI==dev', 'Flask-Script==2.0.3'],
      dependency_links=dep_links)
