candi-aspect (Compile &amp; Install)
=====

The ``candi-aspect.sh`` shell script downloads, configures, builds, and installs [deal.II](https://github.com/dealii/dealii) with common dependencies on linux-based systems(especially for Fedora/Archlinux) for [ASPECT](https://github.com/geodynamics/aspect). You can use this installer to install and compile ASPECT.



Quickstart
----

The following commands download the current stable version of the installer and
then install three versions(in [./version-set](./version-set)) of deal.II release and its correspondent common dependencies:

```bash
  git clone https://github.com/Xjchen0/candi-aspect.git
  cd candi-aspect
  chmod +x ./candi-aspect.sh
  ./candi-aspect.sh -j<N>
```

Process
----

Follow the instructions on the screen
(you can abort the process by pressing < CTRL > + C)

You should install all the dependencies before you start installation.

For Archlinux, it is recommended to install lower versions of GCC.
```bash
  cd ~/Downloads
  wget https://archive.archlinux.org/packages/g/gcc11/gcc11-11.3.0-2-x86_64.pkg.tar.zst https://archive.archlinux.org/packages/g/gcc11-libs/gcc11-libs-11.3.0-2-x86_64.pkg.tar.zst https://archive.archlinux.org/packages/g/gcc11-fortran/gcc11-fortran-11.3.0-2-x86_64.pkg.tar.zst https://archive.archlinux.org/packages/g/gcc10/gcc10-10.2.0-1-x86_64.pkg.tar.zst https://archive.archlinux.org/packages/g/gcc10-libs/gcc10-libs-10.2.0-1-x86_64.pkg.tar.zst https://archive.archlinux.org/packages/g/gcc10-fortran/gcc10-fortran-10.2.0-1-x86_64.pkg.tar.zst
  sudo pacman -U gcc11-11.3.0-2-x86_64.pkg.tar.zst gcc11-libs-11.3.0-2-x86_64.pkg.tar.zst gcc11-fortran-11.3.0-2-x86_64.pkg.tar.zst gcc10-10.2.0-1-x86_64.pkg.tar.zst gcc10-libs-10.2.0-1-x86_64.pkg.tar.zst gcc10-fortran-10.2.0-1-x86_64.pkg.tar.zst
```

When the installer starts, you will choose a version from:
```bash
  Available ASPECT versions:
  1) v3.0.0
  2) aspect-2.5
  3) aspect-2.4
  Select ASPECT version (1-3): 
```
These are stable versions available at [ASPECT](https://github.com/geodynamics/aspect)

Then you will switch the version of GCC by creating symlinks under the directory /usr/local/bin/. Reinstalling openmpi is a good way to eatablish links between mpi and gcc.

If error occurred while installing, you should run `./clean.sh` manually to clean intermediate files under `candi-aspect` directory. And in the next installation, you are recommended to choose `y` when it ask `Clean your past build?(y/N)`. However, if you just install another version of ASPECT which you plan to compile with the same GCC compiler and deal.II that you have successfully launched, you don't need to clean your past build.

At last, if your version of gcc is changed, you can run ./candi_pre/gcc_version_change1x.sh or the shell script in your aspect directory.

If you want to know more about version mapping, you can check [Why use candi-aspect](###Why)

### Examples

You'd better use the origin installer from [deal.II/candi](https://github.com/dealii/candi) if your system is the same as what shown below.

#### Install deal.II on RHEL 7, CentOS 7:
```bash
  module load mpi/openmpi-`uname -i`
  ./candi.sh
```

#### Install deal.II on Ubuntu (16.04), 18.04, 20.xx:
```bash
  ./candi.sh
```

#### Install deal.II on macOS (experimental):
```bash
  ./candi.sh
```

#### Install deal.II on Windows 10 (1709):
Since the Creators Update in fall 2017 (Windows 10 (1709)) the
Windows Subsystem for Linux (WSL) is an official part.

For a detailed instruction how to install WSL, the new WSL 2 and a recent
Ubuntu distribution on Windows 10 you can follow the
[Microsoft Documentation](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

Within the Ubuntu terminal application, upgrade Ubuntu first, then
clone this repository and run candi

```bash
  sudo apt-get update
  sudo apt-get upgrade
  git clone https://github.com/dealii/candi.git
  cd candi
  ./candi.sh
```

#### Install deal.II on a generic Linux system or cluster:
```bash
  ./candi.sh --platform=./deal.II-toolchain/platforms/supported/linux_cluster.platform
```

Note that you probably also want to change the prefix path, or 
the path to ``BLAS`` and ``LAPACK`` in the configuration file
(see documentation below).

Note that in this case you will need to activate the installation of git by
uncommenting the line `#PACKAGES="${PACKAGES} once:git"` in
[candi.cfg](candi.cfg).

It is recommended to edit local_example.cfg to config deal.II by self.


Advanced Configuration
----

### Command line options

#### Help: ``[-h]``, ``[--help]``
You can get a list of all command line options by running
```bash
  ./candi.sh -h
  ./candi.sh --help
```

You can combine the command line options given below.

#### Prefix path: ``[-p <path>]``, ``[-p=<path>]``, ``[--prefix=<path>]``
```bash
  ./candi.sh -p "/path/to/install/dir"
  ./candi.sh -p="/path/to/install/dir"
  ./candi.sh --prefix="/path/to/install/dir"
```

#### Multiple build processes: ``[-j<N>]``, ``[-j <N>]``, ``[--jobs=<N>]``
```bash
  ./candi.sh -j<N>
  ./candi.sh -j <N>
  ./candi.sh --jobs=<N>
```

* Example: to use 2 build processes type ``./candi.sh -j 2``.
* Be careful with this option! You need to have enough system memory (e.g. at
  least 8GB for 2 or more processes).

#### Specific platform: ``[-pf=<platform>]``, ``[--platform=<platform>]``
```bash
  ./candi.sh -pf=./deal.II-toolchain/platforms/...
  ./candi.sh --platform=./deal.II-toolchain/platforms/...
```

If your platform is not detected automatically you can specify it with this
option manually. As shown above, this option is used to install deal.II via
candi on linux clusters, for example. For a complete list of supported platforms
see [deal.II-toolchain/platforms](deal.II-toolchain/platforms).

#### User interaction: ``[-y]``, ``[--yes]``, ``[--assume-yes]``
```bash
  ./candi.sh -y
  ./candi.sh --yes
  ./candi.sh --assume-yes
```

With this option you skip the user interaction. This might be useful if you
submit the installation to the queueing system of a cluster.


### Configuration file options

If you want to change the set of packages to be installed,
you can enable or disable a package in the configuration file
[candi.cfg](candi.cfg).
This file is a simple text file and can be changed with any text editor.

Currently, we provide the packages

* trilinos
* petsc, slepc
* superlu_dist (to be used with trilinos)
* p4est
* hdf5
* opencascade

and others. For a complete list see
[deal.II-toolchain/packages](deal.II-toolchain/packages).

There are several options within the configuration file, for example:

* Remove existing build directories to use always a fresh setup
```bash
  CLEAN_BUILD={ON|OFF}
```

* Enable native compiler optimizations like ``-march=native``
```bash
  NATIVE_OPTIMIZATIONS={ON|OFF}
```

* Enable the build of the deal.II examples
```bash
  BUILD_EXAMPLES={ON|OFF}
```

and more.

Furthermore you can specify the install directory and other internal
directories, where the source and build files are stored:
* The ``DOWNLOAD_PATH`` folder (can be safely removed after installation)
* The ``UNPACK_PATH`` folder of the downloaded packages (can be safely removed
  after installation)
* The ``BUILD_PATH`` folder (can be safely removed after installation)
* The ``INSTALL_PATH`` destination folder


### Single package installation mode

If you prefer to install only a single package, you can do so by
```bash
  ./candi.sh --packages="dealii"
```
for instance, or a set of packages by
```bash
  ./candi.sh --packages="opencascade petsc"
```

### Developer mode

Our installer provides a software developer mode by setting
``DEVELOPER_MODE=ON``
within [candi.cfg](candi.cfg).

More precisely, the developer mode skips the package ``fetch`` and ``unpack``,
everything else (package configuration, building and installation) is done
as before.

Note that you need to have a previous run of candi and
you must not remove the ``UNPACK_PATH`` directory.
Then you can modify source files in ``UNPACK_PATH`` of a package and
run candi again.

### Why use candi-aspect
- GCC is too new for ASPECT and deal.II in systems that are rolling updated.
- Using latest deal.II to compile ASPECT would make ASPECT broken.
- If you want use several versions of ASPECT, you will install and compile different versions of deal.II and its dependencies, but some should be compiled by gcc-10 while others by gcc-11. Thus, there is necessity to divide these into different directories.

How to make versions mapped?
- deal.II version 9.5 and lower need C++14 standard library but 9.6 and newer need C++17(referred from [deal.II_developer_README](https://www.dealii.org/developer/readme.html#supported))
- Trilinos is depended on by deal.II and it changed C++14 to C++17 when it was updated to version 13.4(referred from [an issue of trilinos](https://github.com/trilinos/Trilinos/issues/6260#issuecomment-2712630461)).
- Though we can use one version of GCC to use different C++ libraries, `candi` or the dependencies' `CMakefile` seems to not explicitly select it with the `-std=c++xx` command-line flag. The information about GCC and its default C++ library are available at https://gcc.gnu.org/projects/cxx-status.html#cxx17
- ASPECT is compiled with deal.II and its dependencies are listed at its GitHub repositories `https://github.com/geodynamics/aspect/tree/<branch>`