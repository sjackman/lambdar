# Lambdar: Build R for Amazon Linux and deploy to AWS Lambda
name=lambdar

R_VERSION=3.3.2
BIOC_VERSION=3.4

.DELETE_ON_ERROR:
.SECONDARY:

all: $(name).zip

deploy: $(name).zip.json

# Bundle up R and all of its dependencies
r-%.tar.gz: lambdar.mk
	docker run -v $(PWD):/xfer -w /xfer henrikbengtsson/amazonlinux-r-minimal make -f lambdar.mk

test-version: r-$(R_VERSION).tar.gz
	docker run --env R_VERSION=$(R_VERSION) -v $(PWD):/xfer -w /xfer amazonlinux bash -C test-r.sh

test-r-interactive.sh: test-r.sh
	@cp test-r.sh test-r-interactive.sh
	@echo "echo \"options(repos=c(CRAN='https://cloud.r-project.org', BioCsoft='https://bioconductor.org/packages/$(BIOC_VERSION)/bioc', BioCann='https://bioconductor.org/packages/$(BIOC_VERSION)/data/annotation', BioCexp='https://bioconductor.org/packages/$(BIOC_VERSION)/data/experiment', BioCextra='https://bioconductor.org/packages/$(BIOC_VERSION)/extra', CRANextra='https://www.stats.ox.ac.uk/pub/RWin'))\" >> ~/.Rprofile" >> test-r-interactive.sh
	@echo bash >> test-r-interactive.sh

test: r-$(R_VERSION).tar.gz test-r-interactive.sh
	docker run -it --env R_VERSION=$(R_VERSION) -v $(PWD):/xfer -w /xfer amazonlinux bash -C test-r-interactive.sh

# Build the zip archive for AWS Lambda
%.zip: %.js r-$(R_VERSION).tar.gz
	zip -qr $@ $^

# Deploy the zip to Lambda
%.zip.json: %.zip
	aws lambda update-function-code --function-name $* --zip-file fileb://$< > $@

clean:
	@rm -f r-$(R_VERSION).tar.gz
	@rm $(name).zip
