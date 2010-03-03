/* imvirt / Generic detection code
 *
 * $Id$
 *
 * Authors:
 *   Thomas Liske <liske@ibh.de>
 *
 * Copyright Holder:
 *   2009 - 2010 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

#include "config.h"

extern int debug_cpuid;

void helper_main(int, char **);

#define CPUID(idx,a,b,c,d)\
  asm volatile("cpuid": "=a" (a), "=b" (b), "=c" (c), "=d" (d) : "0" (idx)); \
  if(debug_cpuid) fprintf(stderr, "%s:%d\tCPUID[0x%x]: eax=%d ebx=%d ecx=%d edx=%d\n", __FILE__, __LINE__, idx, a, b, c,d)
