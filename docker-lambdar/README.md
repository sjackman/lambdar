# Short Description

Amazon AWS Lambda environment extended with a build environment containing a minimalistic R


# Full Description

The [lambci/lambda](https://hub.docker.com/r/lambci/lambda/) images reproduce the Amazon AWS Lambda environment as far as possible.  This image ([Dockerfile](https://github.com/HenrikBengtsson/lambdar)) extends their `lambci/lambda:build` image by providing a minimalistic [R](https://www.r-project.org/) installation.

Note that this is a _build environment_ containing a minimalistic R installation.  It requires more work in order to deploy the R software on AWS Lambda.
