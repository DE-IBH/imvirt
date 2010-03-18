if X86ARCH
libexec_PROGRAMS = hvm hyperv vmware xen pillbox

hvm_SOURCES =			\
	detect.c		\
	detect.h		\
	hvm.c

hyperv_SOURCES =		\
	detect.c		\
	detect.h		\
	hyperv.c

vmware_SOURCES =		\
	detect.c		\
	detect.h		\
	vmware.c

xen_SOURCES =			\
	detect.c		\
	detect.h		\
	xen.c

endif

AM_CFLAGS = -Wall
AM_LDFLAGS = -Wl,--as-needed
