# ImVirt - I'm virtualized?
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt::Utils::jiffies;

use strict;
use warnings;
use File::Slurp;
use ImVirt::Utils::procfs;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    jiffies_hz
    jiffies_sec
);

our $VERSION = '0.1';

my @HZ = qw(100 250 300 1000);
my $hz = undef;

sub jiffies_hz() {
    return $hz if(defined($hz));

    my $uptime = procfs_read('uptime');
    my $tlist = procfs_read('timer_list');

    unless(defined($uptime) && defined($tlist)) {
	ImVirt::debug(__PACKAGE__, "could not get timing data from procfs");
	return undef;
    }

    $uptime =~ s/\s.+$//;
    $tlist =~ /^jiffies: (\d+)$/m;
    my $jiffies = $1 % (2**32);

    $hz = $jiffies / $uptime;
    ImVirt::debug(__PACKAGE__, "calculated jiffies: $hz");

    foreach my $h (@HZ) {
	if(abs($h - $hz) < $h*0.1) {
	    $hz = $h;
	    ImVirt::debug(__PACKAGE__, "estimated jiffies: $hz");
	    last;
	}
    }

    return $hz;
}

sub jiffies_sec($) {
    jiffies_hz();

    return (shift) / $hz if(defined($hz));

    return undef;
}

1;
