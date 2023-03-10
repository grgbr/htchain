About
#####

HtChain is a native host toolchain providing multiple tools allowing to build
and assemble software components.

.. important::
   
   Tools chains are meant to run onto **x86_64 GNU/Linux** hosts only.
  
motivation: long term, stable, no dependency on Linux distribution, testing
strategy, available on common debian package based distrib

.. include:: ../generated/packages.rst

Supported platforms
###################

As of today, the following toolchain support is provided :

:a38x: Marvell Armada 38x SoC based platforms

.. table:: Toolchains components

   +----------------+-----------------------------+
   |                | Toolchains                  |
   + Components     +-----------------------------+
   |                | a38x                        |
   +================+=============================+
   | autoconf       | 2.69                        |
   +----------------+-----------------------------+
   | automake       | 1.16.1                      |
   +----------------+-----------------------------+
   | libtool        | 2.4.6                       |
   +----------------+-----------------------------+
   | pkg-config     | 0.26.2                      |
   +----------------+-----------------------------+
   | binutils       | 2.32                        |
   +----------------+-----------------------------+
   | gcc            | 8.3.0                       |
   +----------------+-----------------------------+
   | glibc6         | 2.29                        |
   +----------------+-----------------------------+
   | packager       | crosstool-ng 1.24.0         |
   +----------------+---------------+-------------+

Toolchain default settings are described into the table below [1]_.

.. table:: Default toolchains gcc / glibc settings

   +-------------------------------+------------------------------------+
   | gcc / glibc settings          | Toolchains                         |
   +-------------+-----------------+------------------------------------+
   | Name        | GCC switch      | a38x                               |
   +=============+=================+====================================+
   | ABI         | -mabi           | aapcs-linux                        |
   +-------------+-----------------+------------------------------------+
   | TLS model   | -mtls-dialect   | gnu                                |
   +-------------+-----------------+------------------------------------+
   | Arch        | -march          | armv7-a+mp+sec+simd                |
   +-------------+-----------------+------------------------------------+
   | float ABI   | -mfloat-abi     | hard                               |
   +-------------+-----------------+------------------------------------+
   | FPU         | -mfpu           | neon-vfpv3                         |
   +-------------+-----------------+------------------------------------+
   | Instruction | -mthumb / -marm | ARM  (with no interwork)           |
   | state       |                 |                                    |
   +-------------+-----------------+------------------------------------+
   | CPU         | -mcpu / -mtune  | cortex-a9                          |
   +-------------+-----------------+------------------------------------+
   | system tuple                  | armv7_a38x-xtchain-linux-gnueabihf |
   +-------------------------------+------------------------------------+


Build / install workflow
########################

Prerequisites
*************

Packages listed below are required to build and install cross toolchains onto
your development host :

* coreutils
* tar
* patch
* help2man
* gcc
* g++
* make
* autoconf
* automake
* libtool / libtool-bin
* libncurses5-dev
* git
* ssh
* pkg-config
* flex
* bison
* texinfo
* texlive / texlive-formats-extra / latexmk
* gawk
* rsync
* python3-sphinx / python3-sphinx-rtd-theme
* unzip
* fakeroot

Main Makefile comes with a *prepare* target allowing to install all required
packages (see `Build`_ section).
  
Getting help
************

From XtChain source tree root, enter :

.. code-block:: console

   $ make help

Build
*****

First of all, install all required dependencies :

.. code-block:: console

   $ make prepare

Building toolchain *a38x* is performed out of source tree like so :

.. code-block:: console

   $ make build-a38x BUILDDIR=/tmp/xtchain_build PREFIX=/opt/xtchain

This will basically build every components of the *a38x* toolchain :

* under the */tmp/xtchain_build* directory ;
* using */opt/xtchain/a38x* as the futur install directory path.

Install
*******

Installing toolchain *a38x* is performed according to the following
command :

.. code-block:: console

   $ make install-a38x BUILDDIR=/tmp/xtchain_build PREFIX=/opt/xtchain
   
This instructs to deploy / install built components found under :

* the */tmp/xtchain_build* directory ;
* under the */opt/xtchain/a38x* directory path.

If you want to install the toolchain into a system-wide directory, you will most
likely need root priviledge to run the above command.

Install directory hierarchy
***************************

The directory hierarchy installed by the example commands above is show below.

.. code-block:: console

   $ ls -l /opt/xtchain/a38x/
   total 28
   drwxr-xr-x  7 greg home 4096 Aug 22 18:22 .
   drwxr-xr-x  3 greg home 4096 Aug 22 20:13 ..
   dr-xr-xr-x  8 greg home 4096 Aug 22 18:52 armv7_a38x-xtchain-linux-gnueabihf
   drwxr-xr-x  2 greg home 4096 Aug 22 18:21 bin
   drwxr-xr-x  3 greg home 4096 Aug 22 18:21 include
   drwxr-xr-x  2 greg home 4096 Aug 22 18:21 lib
   drwxr-xr-x 11 greg home 4096 Aug 22 18:06 share

In the excerpt above :

* tools generating objects for target will be found under the
  *armv7_a38x-xtchain-linux-gnueabihf* directory
* development host only tools will be found into *bin", *include*, *lib* and
  *share* remaining directories.

Adding a new toolchain
######################

.. todo::
   Complete me !

TODO
####

An unordered list of futur improvements :

* alternative DESTDIR install location
* debian packaging (depends on DESTDIR support)
* additional components ??
* enable glibc libmvec support
* flex / bison
* gawk perl python2/3 cpio fakeroot bc
* make / cmake / gcc / g++ / libc6-dev ?

.. [1] gcc / glibc settings retrieved according to the command :
       :code:`gcc -Q --help=target`
