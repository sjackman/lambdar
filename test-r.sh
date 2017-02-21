tar xf r-${R_VERSION}.tar.gz -C /tmp
export PATH=/tmp/r/${R_VERSION}/bin:${PATH}
export LD_LIBRARY_PATH=/tmp/r/${R_VERSION}/lib64/R/lib
Rscript -e "cat('R.home():', R.home(), '\n')"
Rscript --version
