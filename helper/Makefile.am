if X86ARCH
libexec_PROGRAMS = hvm hyperv vmware xen

hvm_SOURCES =			\
	detect.c		\
	detect.h		\
	hvm.c			\
	hvm.h

hyperv_SOURCES =			\
	detect.c		\
	detect.h		\
	hyperv.c			\
	hyperv.h

vmware_SOURCES =			\
	detect.c		\
	detect.h		\
	vmware.c			\
	vmware.h

xen_SOURCES =			\
	detect.c		\
	detect.h		\
	xen.c			\
	xen.h
endif

AM_CFLAGS = -Wall
AM_LDFLAGS = -Wl,--as-needed
