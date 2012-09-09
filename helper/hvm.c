/* imvirt / Generic HyperVisor Manager detection code
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

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "detect.h"

int main(int argc, char **argv) {
    helper_main(argc, argv);

    uint32_t eax = 0, ebx = 0, ecx = 0, edx = 0;
    char signature[13];

    CPUID(0x40000000, eax, ebx, ecx, edx);
    memcpy(&signature[0], &ebx, 4);
    memcpy(&signature[4], &ecx, 4);
    memcpy(&signature[8], &edx, 4);
    signature[12] = 0;

    /* P4 reports '@' */
    if((eax == 64) &&
       (ebx == 64) &&
       (ecx ==  0) &&
       (edx == 0))
	return 0;

    if(strlen(signature) && isprint(signature[0])) {
	printf("%s\n", signature);
	return 1;
    }

    return 0;
}
