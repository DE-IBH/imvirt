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
 * This code retrieves multiple processor registers (using SIDT, SGDT,
 * SLDT and STR calls).
 *
 * More details can be found in:
 *  "On the Cutting Edge: Thwarting Virtual Machine Detection"
 *  by Tom Liston, Ed Skoudis
 *  at http://www.offensivecomputing.net/files/active/0/vm.pdf
 */

#include <stdio.h>
#include <stdlib.h>

int main () {
  unsigned int loc;
  loc = 0;
  asm("sidt %0\n" : :"m"(loc));
  printf("idt,%#x,", loc);

  loc = 0;
  asm("sgdt %0\n" : :"m"(loc));
  printf("gdt,%#x,", loc);

  loc = 0;
  asm("sldt %0\n" : :"m"(loc));
  printf("ldt,%#x,", loc);

  loc = 0;
  asm("str %0\n" : :"m"(loc));
  printf("tr,%#x\n", loc);

  exit(0);
}
