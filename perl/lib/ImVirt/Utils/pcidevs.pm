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

package ImVirt::Utils::pcidevs;

use strict;
use warnings;
use Data::Dumper;
use IO::Handle;
use ImVirt::Utils::run;
use ImVirt::Utils::procfs;
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    pcidevs_get
);

our $VERSION = '0.1';

my %pcidevs;

if(procfs_isdir('bus/pci')) {
    pipe(PARENT_RDR, CHILD_WTR);
    if(my $pid = fork()) {
	close(CHILD_WTR);
	foreach my $line (<PARENT_RDR>) {
	    chomp($line);
	    unless($line =~ /^([\da-f:.]+) "(.*)" "(.*)" "(.*)" ([^"]*) ?"(.*)" "(.*)"$/) {
		warn "Unexpected output from lspci: $line\n";
		next;
	    }

	    $pcidevs{$1} = {
		'addr' => $1,
		'type' => $2,
		'vendor' => $3,
		'device' => $4,
		'rev' => $5,
	    };
	}
	close(PARENT_RDR);
    } else {
	die "Cannot fork: $!\n" unless defined($pid);

	close(PARENT_RDR);
	open(STDOUT, '>&CHILD_WTR') || die "Could not dup: $!\n";

	run_exec('lspci', '-m');

	exit;
    }
    ImVirt::debug(__PACKAGE__, Dumper(\%pcidevs));
}
else {
    ImVirt::debug(__PACKAGE__, "procfs does not contain a bus/pci directory");
}

sub pcidevs_get() {
    return %pcidevs;
}

1;
