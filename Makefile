# Lambdar: Run R on AWS Lambda
name=lambdar

rversion=3.3.2

.DELETE_ON_ERROR:
.SECONDARY:

all: $(name).zip

deploy: $(name).zip.json

# Bundle up R and all of its dependencies
r-%.tar.gz:
	docker run -v $(PWD):/xfer -w /xfer henrikbengtsson/amazonlinux-r-minimal make -f lambdar.mk

test: r-$(rversion).tar.gz
	docker run -i -t -v $(PWD):/xfer -w /xfer amazonlinux

# Build the zip archive for AWS Lambda
%.zip: %.js r-$(rversion).tar.gz
	zip -qr $@ $^

# Deploy the zip to Lambda
%.zip.json: %.zip
	aws lambda update-function-code --function-name $* --zip-file fileb://$< > $@

clean:
	@rm -f r-$(rversion).tar.gz
	@rm $(name).zip
