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

package ImVirt::Utils::cpuinfo;

use strict;
use warnings;
use Data::Dumper;
use ImVirt::Utils::procfs;

use constant {
    CPUINFO_UNKNOWN	=> 'UNKNOWN',
};

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    cpuinfo_get
    cpuinfo_hasflags
    CPUINFO_UNKNOWN
);

our $VERSION = '0.1';

my %cpuinfo;
my $fn = procfs_getmp().'/cpuinfo';
if(open(HCPUINFO, $fn)) {
    my $proc;
    while(my $line = <HCPUINFO>) {
	chomp($line);
	if($line =~ /^(\w[^:]+\S)\s+: (.+)$/) {
	    $proc = $2 if($1 eq 'processor');
	    ${$cpuinfo{$proc}}{$1} = $2;
	}
    }
    close(HCPUINFO);
}
else {
    ImVirt::debug(__PACKAGE__, "Cannot open '$fn': $!");

    $cpuinfo{0} = {
	processor => 0,
	vendor_id => CPUINFO_UNKNOWN,
	flags => '',
	model => CPUINFO_UNKNOWN,
	'model name' => CPUINFO_UNKNOWN,
    }
}
ImVirt::debug(__PACKAGE__, Dumper(\%cpuinfo));

sub cpuinfo_get() {
    return %cpuinfo;
}

sub cpuinfo_hasflags(%) {
    my %regexs = @_;
    my $pts = 0;

    foreach my $cpuinfo (keys %cpuinfo) {
	next unless(exists(${$cpuinfo{$cpuinfo}}{'flags'}));

	foreach my $regex (keys %regexs) {
	    $pts += $regexs{$regex} if(${$cpuinfo{$cpuinfo}}{'flags'} =~ /$regex/);
	}
    }

    return $pts;
}

1;
