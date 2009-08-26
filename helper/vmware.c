/* imvirt / VMware detection code
 *
 * $Id$
 *
 * Authors:
 *   Thomas Liske <liske@ibh.de>
 *
 * Copyright Holder:
 *   2009 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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
#include "detect.h"
#include "vmware.h"

#define VMWARE_MAGIC 0x564d5868
#define VMWARE_PORT 0x5658

#define VMWARE_CMD_GETVERSION 0x0a

#define VMWARE_CMD(cmd, eax, ebx, ecx, edx) \
    __asm__("inl (%%dx)" : \
    "=a"(eax), "=c"(ecx), "=d"(edx), "=b"(ebx) : \
    "0"(VMWARE_MAGIC), "1"(VMWARE_CMD_##cmd), \
    "2"(VMWARE_PORT), "3"(0) : \
    "memory");

static int failed;

static void sigh(int signum) {
    failed = 1;
}

int detect_vmware() {
    uint32_t eax, ebx, ecx, edx;
    struct sigaction sa;

    /* ignore SIGSEGV (VMWARE_CMD will cause a SEGV on none VMware systems) */
    sa.sa_handler = sigh;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGSEGV, &sa, NULL);

    failed = 0;

    VMWARE_CMD(GETVERSION, eax, ebx, ecx, edx);

    if(failed)
	return 0;

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
