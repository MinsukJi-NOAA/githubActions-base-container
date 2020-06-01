- Docker image to be used by ufs-weather-model for continuous integration
- Install tool chains and dependencies needed by ufs-weather-model
- Adapted from simple-ufs: https://github.com/DusanJovic-NOAA/simple-ufs
- Base image is CentOS 7
- Install as root the following:
  - gcc 8.3.1 (/opt/rh/devtoolset-8/root/usr/bin/)
  - cmake 3.17.0 (/usr/local/cmake/bin/)
  - mpich 3.3.1 (/usr/local/mpich3/)

  - hdf5 1.10.6 (/usr/local/)
  - netcdf 4.7.3 (/usr/local/)
  - netcdf-fortran 4.5.2 (/usr/local/)
  - esmf 8.0.0 (/usr/local/)

  - ncep libararies release/public-v1 (/usr/local/NCEPlibs/)
- Image can be downloaded from: https://hub.docker.com/r/minsukjinoaa/ufs-weather-model-ci-docker
