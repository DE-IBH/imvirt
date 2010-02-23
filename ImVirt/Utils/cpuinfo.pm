# ImVirt - I'm virtualized?
#
# $Id$
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2010 (C) IBH IT-Service GmbH [http://www.ibh.de/]
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this package; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

package ImVirt::Utils::cpuinfo;

use strict;
use warnings;
use IO::Handle;
use ImVirt::Utils::procfs;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    cpuinfo_read
);

our $VERSION = '0.1';

sub cpuinfo_read() {
    open(HCPUINFO, procfs_getmp().'/cpuinfo') || die;

    my %res;
    my $proc;
    while(my $line = <HCPUINFO>) {
	chomp($line);
	if($line =~ /^(\w[^:]+\S)\s+: (.+)$/) {
	    $proc = $2 if($1 eq 'processor');
	    ${$res{$proc}}{$1} = $2;
	}
    }
    close(HCPUINFO);

    return %res;
}

1;
