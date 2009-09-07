if X86ARCH
libexec_PROGRAMS = detect

detect_SOURCES =			\
	detect.c			\
	detect.h			\
	hyperv.c			\
	hyperv.h			\
	hvm.c				\
	hvm.h				\
	vmware.c			\
	vmware.h			\
	xen.c				\
	xen.h
endif

AM_CFLAGS = -Wall
AM_LDFLAGS = -Wl,--as-needed
