# lambdar: Build R to run on AWS Lambda

R_VERSION=3.3.2
R_PREFIX=/tmp/r/$(R_VERSION)

.DELETE_ON_ERROR:
.SECONDARY:

all: r-$(R_VERSION).tar.gz

# Build R from source
/tmp/r/%: /tmp/R-%
	cd /tmp/R-$*;\
	./configure --with-readline=${R_READLINE} --without-x --without-libtiff --without-jpeglib --without-cairo --without-lapack --without-ICU --without-recommended-packages --disable-R-profiling --disable-java --disable-nls --prefix=${R_PREFIX}; \
	make; \
	make install

# Copy dependencies from amazonlinux-minimal-r build
lib/%: /tmp/r/$(R_VERSION)
	cp $(shell ldconfig -p | grep $(@F) | sed 's|.*=> ||g') $(R_PREFIX)/lib64/R/lib

# Build the tarball of R and all of its dependencies
r-%.tar.gz: /tmp/r/% lib/libgfortran.so.3 lib/libquadmath.so.0 lib/libgomp.so.1
	tar zcf $@ -C /tmp r/$*
