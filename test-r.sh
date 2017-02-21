tar xf r-${R_VERSION}.tar.gz -C /tmp
export PATH=/tmp/r/${R_VERSION}/bin:${PATH}
export LD_LIBRARY_PATH=/tmp/r/${R_VERSION}/lib64/R/lib
Rscript -e "cat('R.home():', R.home(), '\n')"
Rscript -e "sessionInfo()"
if [[ ${INTERACTIVE} == "true" ]]; then
    export R_BIOC_VERSION=3.4
    mkdir /tmp/test
    cd /tmp/test
    echo "R_BIOC_VERSION=${R_BIOC_VERSION}" >> .Renviron
    echo "options(repos = c(CRAN='https://cloud.r-project.org', BioCsoft='https://bioconductor.org/packages/${R_BIOC_VERSION}/bioc', BioCann='https://bioconductor.org/packages/${R_BIOC_VERSION}/data/annotation', BioCexp='https://bioconductor.org/packages/${R_BIOC_VERSION}/data/experiment', BioCextra='https://bioconductor.org/packages/${R_BIOC_VERSION}/extra'))" >> .Rprofile
    bash;
fi
