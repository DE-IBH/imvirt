/* imvirt / Red Pill et. al. code
 *
 * $Id$
 *
 * Authors:
 *   Thomas Liske <liske@ibh.de>
 *
 * Copyright Holder:
 *   2010 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

/*
 * This code retrieves the Global Descriptor Table Register
 * and checks for a constant value on one CPU.
 *
 * More details can be found in:
 *  "On the Cutting Edge: Thwarting Virtual Machine Detection"
 *  by Tom Liston, Ed Skoudis
 *  at http://www.offensivecomputing.net/files/active/0/vm.pdf
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <unistd.h>
#include <sched.h>

int main () {
  cpu_set_t mask;

  if(sched_getaffinity(0, sizeof(mask), &mask) < 0) {
    perror("sched_getaffinity");
    return -1;
  }

  /* Retrieve first online cpu. */
  int n;
  for(n = 0; n < CPU_SETSIZE; n++) {
    if(CPU_ISSET(n, &mask)) {
	CPU_ZERO(&mask);
	CPU_SET(n, &mask);
	break;
    }
  }
  if(!CPU_ISSET(n, &mask)) {
    fprintf(stderr, "Oops, could not find an online CPU!\n");
    return -1;
  }

  if (sched_setaffinity(0, sizeof(mask), &mask) < 0) {
    perror("sched_setaffinity");
    return -1;
  }

  volatile uint64_t idt = 0;

  asm("sidt %0" : :"m"(idt));
  uint64_t old = idt;

  unsigned int i;
  for(i=0; i<0xffffff; i++) {
    asm("sidt %0" : :"m"(idt));
    if(old != idt) {
	printf("cpu,%d,idt,0x%" PRIx64 ",idt2,0x%" PRIx64 "\n", n, old, idt);
	return 0;
    }
  }

  printf("cpu,%d,idt,0x%" PRIx64 "\n", n, old);
  return 0;
}
