/* imvirt / Xen detection code
 *
 * $Id$
 *
 * This file has been taken from XenSource's xen_detect.c with some small
 * changes to fit imvirt requirements on output / return codes.
 *
 *
 * xen_detect.c
 * 
 * Simple GNU C / POSIX application to detect execution on Xen VMM platform.
 * 
 * Copyright (c) 2007, XenSource Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "detect.h"

#include "hvm.h"
#include "hyperv.h"
#include "vmware.h"
#include "xen.h"

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
