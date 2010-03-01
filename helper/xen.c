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

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include "detect.h"
#include "xen.h"

static int pv_context;

static void cpuid(uint32_t idx, uint32_t *eax, uint32_t *ebx, uint32_t *ecx, uint32_t *edx) {
    asm volatile (
        "test %1,%1 ; jz 1f ; ud2a ; .ascii \"xen\" ; 1: cpuid"
        : "=a" (*eax), "=b" (*ebx), "=c" (*ecx), "=d" (*edx)
        : "0" (idx), "1" (pv_context)
    );
}

static int check_for_xen(void) {
    uint32_t eax, ebx, ecx, edx;
    char signature[13];

    cpuid(0x40000000, &eax, &ebx, &ecx, &edx);
    memcpy(&signature[0], &ebx, 4);
    memcpy(&signature[4], &ecx, 4);
    memcpy(&signature[8], &edx, 4);
    signature[12] = '\0';

    if (strcmp("XenVMMXenVMM", signature) || (eax < 0x40000002))
        return 0;

    cpuid(0x40000001, &eax, &ebx, &ecx, &edx);
    printf("Xen %d.%d %s\n",
           (uint16_t)(eax >> 16), (uint16_t)eax,
           pv_context ? "PV" : "HVM");

    return 1;
}

static void sigh(int signum) {
    exit(0);
}

int main(int argc, char **argv) {
    helper_main(argc, argv);

    pid_t pid;
    int status;
    uint32_t dummy;

    /* Check for execution in HVM context. */
    if (check_for_xen())
        return 0;

    /* Now we check for execution in PV context. */
    pv_context = 1;

    /*
     * Fork a child to test the paravirtualised CPUID instruction.
     * If executed outside Xen PV context, the extended opcode will fault.
     */
    pid = fork();
    switch ( pid )
    {
    case 0:
        /* ignore SIGILL on amd64 */
        {
            struct sigaction sa;

            sa.sa_handler = sigh;
            sigemptyset(&sa.sa_mask);
            sa.sa_flags = 0;
            sigaction(SIGILL, &sa, NULL);
        }

        /* Child: test paravirtualised CPUID opcode and then exit cleanly. */
        cpuid(0x40000000, &dummy, &dummy, &dummy, &dummy);
        exit(1);
    case -1:
//        fprintf(stderr, "Fork failed.\n");
        return 0;
    }

    /*
     * Parent waits for child to terminate and checks for clean exit.
     * Only if the exit is clean is it safe for us to try the extended CPUID.
     */
    waitpid(pid, &status, 0);
    if ( WIFEXITED(status) && WEXITSTATUS(status) && check_for_xen() )
        return 0;

//    printf("Not running on Xen.\n");
    return 0;
}
