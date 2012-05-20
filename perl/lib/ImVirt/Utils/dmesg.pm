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

package ImVirt::Utils::dmesg;

use strict;
use warnings;
use IO::Handle;
use File::Slurp;
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    dmesg_match
);

our $VERSION = '0.1';

my $dmesg = '/bin/dmesg';
my $logfile = '/var/log/dmesg';

sub dmesg_match(%) {
    return -1 unless (-x $dmesg || -r $logfile);

    my %regexs = @_;
    my $pts = 0;
    my %lines;

    if(-x $dmesg) {
	pipe(PARENT_RDR, CHILD_WTR);
	if(my $pid = fork()) {
	    close(CHILD_WTR);
	    %lines = map { $_, 1 } <PARENT_RDR>;
	    close(PARENT_RDR);
	} else {
	    die "Cannot fork: $!\n" unless defined($pid);
	
	    close(PARENT_RDR);
	    open(STDOUT, '>&CHILD_WTR') || die "Could not dup: $!\n";
	
	    exec($dmesg);

	    die("Cannot exec $dmesg: $!\n");
	}
    }

    %lines = (%lines, map { $_, 1 } read_file($logfile)) if(-r $logfile);

    foreach my $line (keys %lines) {
	chomp($line);
	foreach my $regex (keys %regexs) {
	    $pts += $regexs{$regex} if($line =~ /$regex/);
	}
    }

    return $pts;
}

1;
