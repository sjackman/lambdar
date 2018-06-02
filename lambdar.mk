# lambdar: Build R to run on AWS Lambda

R_VERSION=3.3.2

R_PREFIX=/tmp/r/$(R_VERSION)

.DELETE_ON_ERROR:
.SECONDARY:

all: r-$(R_VERSION).tar.xz

# Build R from source
/tmp/r/%: /tmp/R-%
	cd /tmp/R-$*;\
	./configure --with-readline=${R_READLINE} --without-x --without-libtiff --without-jpeglib --without-cairo --without-lapack --without-ICU --without-recommended-packages --disable-R-profiling --disable-java --disable-nls --prefix=${R_PREFIX}; \
	make; \
	make install

prune: /tmp/r/$(R_VERSION)
	@rm -rf $(R_PREFIX)/share
	@rm -f $(R_PREFIX)/lib64/R/COPYING $(R_PREFIX)/lib64/R/SVN-REVISION
	@rm -rf $(R_PREFIX)/lib64/R/doc/*
	@mkdir -p /tmp/r/3.3.2/lib64/R/doc/html ## install.packages()
	@rm -f $(R_PREFIX)/lib64/R/doc/NEWS*
	@rm -rf $(R_PREFIX)/lib64/R/doc/manual*
	@rm -rf $(R_PREFIX)/lib64/R/library/*/doc
	@rm -rf $(R_PREFIX)/lib64/R/library/*/html
	@rm -rf $(R_PREFIX)/lib64/R/library/translations

# Copy dependencies from amazonlinux-minimal-r build
lib/%: /tmp/r/$(R_VERSION)
	cp $(shell ldconfig -p | grep $(@F) | sed 's|.*=> ||g') $(R_PREFIX)/lib64/R/lib

# Build the tarball of R and all of its dependencies
r-%.tar: /tmp/r/% lib/libgfortran.so.3 lib/libquadmath.so.0 lib/libgomp.so.1 prune
	tar cf $@ -C /tmp r/$*

r-%.tar.xz: r-%.tar
	xz -9 $<

r-%.tar.gz: r-%.tar
	gzip -9 $<

clean:
	@rm -rf $(R_PREFIX)
