#!/bin/bash
set -eu
set -o pipefail

usage() {
  echo "Usage: $0 gnu | intel [-all] [-3rdparty] [-nceplibs]"
  exit 1
}

[[ $# -lt 2 ]] && usage

export COMPILER=$1
shift

OS=$(uname -s)
ESMF_OS=${OS}

if [[ $COMPILER == gnu ]]; then
  export CC=${CC:-gcc}
  export CXX=${CXX:-g++}
  export FC=${FC:-gfortran}
  export MPICC=${MPICC:-mpicc}
  export MPICXX=${MPICXX:-mpicxx}
  export MPIF90=${MPIF90:-mpif90}
  ESMF_COMPILER=gfortran
elif [[ $COMPILER == intel ]]; then
  if [[ $(command -v ftn) ]]; then
    # Special case on Cray systems
    export CC=${CC:-cc}
    export CXX=${CXX:-CC}
    export FC=${FC:-ftn}
    export MPICC=${MPICC:-cc}
    export MPICXX=${MPICXX:-CC}
    export MPIF90=${MPIF90:-ftn}
    ESMF_OS=Unicos
    MPI_IMPLEMENTATION=mpi
  else
    export CC=${CC:-icc}
    export CXX=${CXX:-icpc}
    export FC=${FC:-ifort}
    export MPICC=${MPICC:-mpicc}
    export MPICXX=${MPICXX:-mpicxx}
    export MPIF90=${MPIF90:-mpif90}
  fi
  ESMF_COMPILER=intel
else
  usage
fi

BUILD_3RDPARTY=no
BUILD_NCEPLIBS=no

while [[ $# -gt 0 ]]; do
opt=$1

case $opt in
  -all)
    BUILD_3RDPARTY=yes
    BUILD_NCEPLIBS=yes
    shift
    ;;
  -3rdparty)
    BUILD_3RDPARTY=yes
    shift
    ;;
  -nceplibs)
    BUILD_NCEPLIBS=yes
    shift
    ;;
  *)
    echo "unknown option ${opt}"
    usage
esac
done

echo "BUILD_3RDPARTY = ${BUILD_3RDPARTY}"
echo "BUILD_NCEPLIBS = ${BUILD_NCEPLIBS}"

MYDIR=$(cd "$(dirname "$(readlink -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
PREFIX_PATH=/usr/local
# print compiler version
echo
${CC} --version | head -1
${CXX} --version | head -1
${FC} --version | head -1
cmake --version | head -1
echo

OS=$(uname -s)

MPI_IMPLEMENTATION=${MPI_IMPLEMENTATION:-mpich3}
if ! command -v mpiexec > /dev/null ; then
  if [[ -f ${PREFIX_PATH}/${MPI_IMPLEMENTATION}/bin/mpiexec ]]; then
    export PATH=${PREFIX_PATH}/${MPI_IMPLEMENTATION}/bin:$PATH
  else
    echo "Missing mpiexec for ${MPI_IMPLEMENTATION}"
    exit 1
  fi
fi

mpiexec --version | grep OpenRTE 2> /dev/null && MPI_IMPLEMENTATION=openmpi
mpiexec --version | grep Intel 2> /dev/null && MPI_IMPLEMENTATION=intelmpi
mpiexec --version
echo

export MPICH_CC=${CC}
export MPICH_CXX=${CXX}
export MPICH_F90=${FC}
export OMPI_CC=${CC}
export OMPI_CXX=${CXX}
export OMPI_FC=${FC}

#
# 3rdparty
#
if [ $BUILD_3RDPARTY == yes ]; then
printf '%-.30s ' "Building 3rdparty .........................."
(
  cd libs/3rdparty
  ./build.sh ${COMPILER}
) > log_3rdparty 2>&1
echo 'done'
fi

export HDF5=${PREFIX_PATH}
export NETCDF=${PREFIX_PATH}
export ESMFMKFILE=${PREFIX_PATH}/lib/esmf.mk

#
# nceplibs
#
if [ $BUILD_NCEPLIBS == yes ]; then
printf '%-.30s ' "Building nceplibs .........................."
(
  cd libs/nceplibs
  ./build.sh ${COMPILER}
) > log_nceplibs 2>&1
echo 'done'
fi

echo "Done!"
