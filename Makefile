# Lambdar: Run R on AWS Lambda
name=lambdar
rversion=3.3.2

# R must be built on a system compatible with Amazon Linux with glibc <= 2.17.
glibc_version=$(shell ldd --version | head -1 | sed -E 's/.*GLIBC[[:space:]]([0-9.-]+).*/\1/g' | tr - .)
glibc_version_smallest=$(shell printf "$(glibc_version)\n2.17" | sort -V | head -1)
ifeq ($(glibc_version_smallest), 2.17)
  $(error "ERROR: R must be built with GLIBC (<= 2.17) in order to work on AWS Lambda: $(glibc_version)")
endif

.DELETE_ON_ERROR:
.SECONDARY:

all: $(name).zip

debug:
	@echo "R version: $(rversion)"
	@echo "GLIBC version: $(glibc_version)"

deploy: $(name).zip.json

r: /tmp/.linuxbrew/Cellar/r/$(rversion)/INSTALL_RECEIPT.json

# Clone Linuxbrew
/tmp/.linuxbrew/bin/brew:
	git clone --depth 1 https://github.com/Linuxbrew/brew /tmp/.linuxbrew

# Build R
# Must be built on a system compatible with Amazon Linux with glibc <= 2.17.
/tmp/.linuxbrew/Cellar/r/$(rversion)/INSTALL_RECEIPT.json: /tmp/.linuxbrew/bin/brew
	PATH=/tmp/.linuxbrew/bin:$(PATH) brew install -s --without-x11 homebrew/science/r

# Copy R to this directory
.linuxbrew/Cellar/r/%/INSTALL_RECEIPT.json: /tmp/.linuxbrew/Cellar/r/%/INSTALL_RECEIPT.json
	mkdir -p $(@D)
	rm -rf $(@D)
	cp -a $(<D) $(@D)
	sed -i.orig 's~SED=/usr/bin/sed~SED=/bin/sed~' $(@D)/lib/R/bin/R
	## Remove anything not needed (saves ~25%)
	rm $(@D)/README $(@D)/COPYING $(@D)/ChangeLog
	rm -rf $(@D)/share/
	rm -f $(@D)/lib/R/COPYING $(@D)/lib/R/SVN-REVISION
	rm -f $(@D)/lib/R/doc/AUTHORS $(@D)/lib/R/doc/COPYING $(@D)/lib/R/doc/COPYRIGHTS $(@D)/lib/R/doc/FAQ $(@D)/lib/R/doc/NEWS* $(@D)/lib/R/doc/RESOURCES $(@D)/lib/R/doc/THANKS
	rm -rf $(@D)/lib/R/doc/html/ $(@D)/lib/R/doc/manual/
	rm -rf $(@D)/lib/R/library/*/html/
	rm -rf $(@D)/lib/R/library/*/doc/
	touch $@

# Copy dependencies from Linuxbrew
lib/%: /tmp/.linuxbrew/lib/%
	mkdir -p $(@D)
	cp $< $@

# Copy dependencies from /usr/lib64
lib/%: /usr/lib64/%
	mkdir -p $(@D)
	cp $< $@

# Copy dependencies from /usr/lib/ (Ubuntu 16.04)
lib/%: /usr/lib/%
	mkdir -p $(@D)
	cp $< $@

# Copy dependencies from /usr/lib/x86_64-linux-gnu/ (Ubuntu 16.04)
lib/%: /usr/lib/x86_64-linux-gnu/%
	mkdir -p $(@D)
	cp $< $@

# Build the tarball of R and its dependencies
r-%.x86_64_linux.bottle.tar.gz: .linuxbrew/Cellar/r/%/INSTALL_RECEIPT.json
	tar zcf $(PWD)/$@ -C .linuxbrew/Cellar r/$*

# Build the zip archive for Lambda
%.zip: %.js r-$(rversion).x86_64_linux.bottle.tar.gz \
		lib/libatlas.so.3 \
		lib/libbz2.so.1.0 \
		lib/libblas.so.3 \
		lib/libicudata.so.55 \
		lib/libicuuc.so.55 \
		lib/libicui18n.so.55 \
		lib/libgfortran.so.3 \
		lib/libncursesw.so.6 \
		lib/libpcre.so.1 \
		lib/libquadmath.so.0 \
		lib/libreadline.so.7
	zip -qr $@ $^

# Deploy the zip to Lambda
%.zip.json: %.zip
	ls -l $<
	aws --cli-read-timeout 0 --cli-connect-timeout 0 lambda update-function-code --function-name $* --zip-file fileb://$< > $@
	ls -l $@


clean:
	rm $(name).zip

clean-r:
	rm -rf /tmp/.linuxbrew/Cellar/r/$(rversion)/
