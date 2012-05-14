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

#if defined(__i386__) && defined(__PIC__)
#define CPUID(leaf, eax, ebx, ecx, edx)				\
    __asm__ (							\
	"xchgl %%ebx, %1;"					\
	"cpuid;"						\
	"xchgl %%ebx, %1"					\
	: "=a" (eax), "=r" (ebx), "=c" (ecx), "=d" (edx)	\
	: "0" (leaf));						\
    if(debug_cpuid) fprintf(stderr, "%s:%d\tCPUID[0x%x]: eax=%d ebx=%d ecx=%d edx=%d\n", __FILE__, __LINE__, leaf, eax, ebx, ecx, edx)
#else
#define CPUID(leaf, eax, ebx, ecx, edx)				\
    __asm__ (							\
	"cpuid"							\
	: "=a" (eax), "=b" (ebx), "=c" (ecx), "=d" (edx)	\
	: "0" (leaf));						\
    if(debug_cpuid) fprintf(stderr, "%s:%d\tCPUID[0x%x]: eax=%d ebx=%d ecx=%d edx=%d\n", __FILE__, __LINE__, leaf, eax, ebx, ecx, edx)
#endif
