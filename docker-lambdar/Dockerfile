## Build usage:
##  docker build -t henrikbengtsson/lambdar:build .
##
## Run usage:
##  docker run -i -t henrikbengtsson/lambdar:build bash
##
## Source: https://github.com/{HenrikBengtsson|sjackman}/lambdar
## Copyright: Henrik Bengtsson (2017-2018)
## License: GPL (>= 2.1) [https://www.gnu.org/licenses/gpl.html]

FROM lambci/lambda:build

MAINTAINER Henrik Bengtsson "henrikb@braju.com"

RUN yum install -y gcc-gfortran
RUN yum install -y libgfortran     # Otherwise ld error duing 'make'
RUN yum install -y readline-devel  # Required iff --with-readline=yes
RUN yum install -y bzip2-devel
RUN yum install -y xz-devel        # liblzma
RUN yum install -y pcre-devel
RUN yum install -y curl-devel

## Optional
RUN yum install -y libpng-devel

ENV R_VERSION=3.5.0
ENV R_READLINE=yes
ENV R_PREFIX=/tmp/r-local/${R_VERSION}

## Build and install R from source
RUN cd /tmp; curl -O https://cloud.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz
RUN cd /tmp; tar -zxf R-${R_VERSION}.tar.gz
RUN cd /tmp/R-${R_VERSION}; ./configure --with-readline=${R_READLINE} --without-x --without-libtiff --without-jpeglib --without-cairo --without-lapack --without-ICU --without-recommended-packages --disable-R-profiling --disable-java --disable-nls --prefix=${R_PREFIX}
RUN cd /tmp/R-${R_VERSION}; make
RUN cd /tmp/R-${R_VERSION}; make install

## R runtime properties
RUN mkdir ${R_PREFIX}/lib64/R/site-library  ## Where to install packages

ENV PATH=${R_PREFIX}/bin:${PATH}
ENV R_BIOC_VERSION=3.7
RUN echo "R_BIOC_VERSION=${R_BIOC_VERSION}" >> ~/.Renviron
RUN echo "options(repos = c(CRAN='https://cloud.r-project.org', BioCsoft='https://bioconductor.org/packages/${R_BIOC_VERSION}/bioc', BioCann='https://bioconductor.org/packages/${R_BIOC_VERSION}/data/annotation', BioCexp='https://bioconductor.org/packages/${R_BIOC_VERSION}/data/experiment'))" >> ~/.Rprofile
