/* imvirt / pillbox - retrieve several unprivileged registers
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

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <sched.h>

void sidt() {
  volatile uint64_t idt = 0;

  asm("sidt %0" : :"m"(idt));
  volatile uint64_t old = idt;

  unsigned int i;
  for(i=0; i<0xffffff; i++) {
    asm("sidt %0" : :"m"(idt));

    if(old != idt) {
	printf(",idt,%" PRIu64 ",idt2,%" PRIu64, old, idt);
	return;
    }
  }

  printf(",idt,%" PRIu64, old);
}

void sgdt() {
  volatile uint64_t gdt = 0;

  asm("sgdt %0" : :"m"(gdt));
  volatile uint64_t old = gdt;

  unsigned int i;
  for(i=0; i<0xffffff; i++) {
    asm("sgdt %0" : :"m"(gdt));

    if(old != gdt) {
	printf(",gdt,%" PRIu64 ",gdt2,%" PRIu64, old, gdt);
	return;
    }
  }

  printf(",gdt,%" PRIu64, old);
}

void sldt() {
  volatile uint64_t ldt = 0;

  asm("sldt %0" : :"m"(ldt));

  printf(",ldt,%" PRIu64, ldt);
}

void str() {
  volatile uint64_t tr = 0;

  asm("str %0" : :"m"(tr));

  printf(",tr,%" PRIu64, tr);
}

int main () {
  /* Some of the tests need to be run on the same CPU. */
  cpu_set_t mask;

  if(sched_getaffinity(0, sizeof(mask), &mask) < 0) {
    perror("sched_getaffinity");
    return -1;
  }

  /* Bind onto first online cpu. */
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

  printf("cpu,%d", n);

  sidt();
  sgdt();
  sldt();
  str();

  printf("\n");

  exit(0);
}
