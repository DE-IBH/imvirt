/* imvirt / Generic detection code
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

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "detect.h"

int debug_cpuid = 0;

void helper_main(int argc, char **argv) {
    int opts;

    while ((opts = getopt(argc, argv, "c")) != EOF) {
	switch(opts) {
	    case 'c':
		debug_cpuid = 1;
		break;
	    default:
		fprintf(stderr, "Usage: %s [-c]\n\t-c\tdebug CPUID calls\n\n", argv[0]);
		exit(1);
	}
    }
}
