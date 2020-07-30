# $ time spack install gcc@5.4.0
# ...
# ==> Executing phase: 'configure'
# ==> Executing phase: 'build'
# ==> Executing phase: 'install'
# ==> Successfully installed gcc
#   Fetch: 1m 10.42s.  Build: 48m 16.13s.  Total: 49m 26.55s.
# [+] /nas/material02/users/joelb/views/spack/opt/spack/linux-centos7-haswell/gcc-4.8.5/gcc-5.4.0-vq4lsrupcmaebtfyxo73t74lfn26v57u
# 
# real    51m8.877s

# $ spack install boost@1.72.0
# real    12m11.432s

cd mgizapp
spack load gcc@5.4.0
spack load boost@1.72.0
spack load cmake@3.16.2
cmake .
make
make install
