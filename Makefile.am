SUBDIRS = helper man perl dist

AUTOMAKE_OPTIONS = 
	1.9
	dist-bzip2

BUILT_SOURCES = perl

bin_SCRIPTS = imvirt
sbin_SCRIPTS = imvirt-report

install-exec-local:
	[ ! -f perl/Makefile ] || ( cd perl && $(MAKE) install )

clean-local:
	[ ! -f perl/Makefile ] || ( cd perl && $(MAKE) realclean )

perl: perl/Makefile
	cd perl && $(MAKE)

perl/Makefile: perl/Makefile.PL
	cd perl && perl Makefile.PL PREFIX=$(prefix) INSTALLDIRS=vendor

.PHONY: perl
