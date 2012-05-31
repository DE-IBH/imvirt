# ImVirt - I'm virtualized?
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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
use Data::Dumper;
use ImVirt::Utils::procfs;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    kmods_get
    kmods_match
    kmods_match_used
);

our $VERSION = '0.1';

my $procdir = procfs_getmp();
my %kmods;

if(open(HKMS, "$procdir/modules")) {
    while(<HKMS>) {
	chomp;
	if(/^(\S+) (\d+) (\d+) (\S+) (\S+) (0x[a-f\d]+)/) {
	    ${$kmods{$1}}{'size'} = $2;
	    ${$kmods{$1}}{'instances'} = $3;
	    ${$kmods{$1}}{'usedby'} = $4;
	    ${$kmods{$1}}{'state'} = $5;
	    ${$kmods{$1}}{'by'} = $6;
	}
    }
    ImVirt::debug(__PACKAGE__, Dumper(\%kmods));
}
else {
    ImVirt::debug(__PACKAGE__, "failed to open $procdir/modules: $!");
}

sub kmods_get() {
    return %kmods;
}

sub kmods_match(%) {
    my %regexs = @_;
    my $pts = 0;

    foreach my $kmod (keys %kmods) {
	foreach my $regex (keys %regexs) {
	    if($kmod =~ /$regex/) {
		$pts += $regexs{$regex};
		delete($regexs{$regex});
	    }
	}
    }

    return $pts;
}

sub kmods_match_used(%) {
    my %regexs = @_;
    my $pts = 0;

    foreach my $kmod (keys %kmods) {
	foreach my $regex (keys %regexs) {
	    if($kmod =~ /$regex/ && ${$kmods{$kmod}}{'instances'} > 0) {
		$pts += $regexs{$regex};
		delete($regexs{$regex});
	    }
	}
    }

    return $pts;
}

1;
