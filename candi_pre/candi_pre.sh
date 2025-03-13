#!/bin/bash
echo "======GCC VERSION======"
gcc --version | head -n1
echo "mpi version: "
mpicc --version | head -n1

export CC=/usr/bin/mpicc
export CXX=/usr/bin/mpicxx
export FC=/usr/bin/mpif90
export FF=/usr/bin/mpif77
