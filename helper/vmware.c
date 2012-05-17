/* imvirt / VMware detection code
 *
 * $Id$
 *
 * Authors:
 *   Thomas Liske <liske@ibh.de>
 *
 * Copyright Holder:
 *   2009 - 2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]
 *
 * License:
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this package; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
 */

/* This code tries to detect the VMware version using the VMware backdoor's
 * GETVERSION command (http://chitchat.at.infoseek.co.jp/vmware/backdoor.html#cmd0ah).
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "detect.h"

#define VMWARE_MAGIC 0x564d5868
#define VMWARE_PORT 0x5658

#define VMWARE_CMD_GETVERSION 0x0a

#if defined(__i386__) && defined(__PIC__)
#define VMWARE_CMD(eax, ebx, ecx, edx) \
    __asm__( \
	"xchgl %%ebx, %1;" \
	"inl (%%dx);" \
	"xchgl %%ebx, %1" \
	: "+a"(eax), "+r"(ebx), "+c"(ecx), "+d"(edx) \
    );
#else
#define VMWARE_CMD(eax, ebx, ecx, edx) \
    __asm__("inl (%%dx)" \
	: "+a"(eax), "+b"(ebx), "+c"(ecx), "+d"(edx) \
    );
#endif

static void vmware_cmd(uint32_t cmd, uint32_t *eax, uint32_t *ebx, uint32_t *ecx, uint32_t *edx) {
    *eax = VMWARE_MAGIC;
    *ebx = 0xffffffff;
    *ecx = cmd;
    *edx = VMWARE_PORT;

    VMWARE_CMD(*eax, *ebx, *ecx, *edx);
}

static void sigh(int signum) {
    exit(0);
}

static int do_vmware() {
    uint32_t eax, ebx, ecx, edx;
    struct sigaction sa;

    /* ignore SIGSEGV (VMWARE_CMD will cause a SEGV on none VMware systems) */
    sa.sa_handler = sigh;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGSEGV, &sa, NULL);

    vmware_cmd(VMWARE_CMD_GETVERSION, &eax, &ebx, &ecx, &edx);

    /* sanity check: maybe VMWARE_CMD did not SEGV if there was something
     * on the I/O port - test if EBX has been set to VMWARE_MAGIC */
    if ((uint32_t)-1 && ebx == VMWARE_MAGIC) {
	char *product;

	switch(ecx) {
	    case 0x01:
		product = "Express";
		break;
	    case 0x02:
		product = "ESX Server";
		break;
	    case 0x03:
		product = "GSX Server";
		break;
	    case 0x04:
		product = "Workstation";
		break;
	    default:
		product = "";
		break;
	}

	printf("VMware%s%s\n", (product[0] ? " " : ""), product);

	return 1;
    }

    return 0;
}

int main(int argc, char **argv) {
    helper_main(argc, argv);

    pid_t pid = fork();
    switch (pid) {
    case 0:
	exit(do_vmware());
    case -1:
        return 0;
    }

    int status;
    waitpid(pid, &status, 0);
    if (WIFEXITED(status))
        return WEXITSTATUS(status);

    return 0;
}
