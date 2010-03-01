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

package ImVirt::Utils::kmods;

use strict;
use warnings;
use IO::Handle;
use ImVirt::Utils::procfs;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    kmods_get
    kmods_match
);

our $VERSION = '0.1';

my $procdir = procfs_getmp();
my %kmods;

open(HKMS, "$procdir/modules");
while(<HKMS>) {
	chomp;
	if(/^(\S+) (\d+) (\d+) (\S+) (\S+) (0x[a-f\d]+)/) {
	    ${$kmods{$1}}{'size'} = $2;
	    ${$kmods{$1}}{'type'} = $3;
	    ${$kmods{$1}}{'used'} = $4;
	    ${$kmods{$1}}{'state'} = $5;
	    ${$kmods{$1}}{'by'} = $6;
	}
}

sub kmods_get() {
    return %kmods;
}

sub kmods_match(%) {
    my %regexs = @_;
    my $pts = 0;

    foreach my $kmod (keys %kmods) {
	foreach my $regex (keys %regexs) {
	    $pts += $regexs{$regex} if($kmod =~ /$regex/);
	}
    }

    return $pts;
}

1;
