/* imvirt / HyperV detection code
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
#include <unistd.h>
#include <stdlib.h>
#include "detect.h"
#include "hyperv.h"

int main(int argc, char **argv) {
    helper_main(argc, argv);

    uint32_t eax = 0, ebx = 0, ecx = 0, edx = 0;
    char signature[13];

    CPUID(0x40000000, eax, ebx, ecx, edx);
    memcpy(&signature[0], &ebx, 4);
    memcpy(&signature[4], &ecx, 4);
    memcpy(&signature[8], &edx, 4);
    signature[12] = 0;

    if(!strcmp(signature, "Microsoft Hv")) {
	printf("Virtual Machine\n");
	return 1;
    }

    return 0;
}
