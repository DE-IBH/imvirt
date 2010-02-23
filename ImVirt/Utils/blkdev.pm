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

package ImVirt::Utils::blkdev;

use strict;
use warnings;
use IO::Handle;
use File::Slurp;
use ImVirt::Utils::procfs;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    blkdev_match
);

our $VERSION = '0.1';

sub blkdev_match(%) {
    my %regexs = @_;
    my $pts = 0;

    # scan SCSI devices
    if(my @scsi = procfs_read('scsi/scsi')) {
	foreach my $scsi (@scsi) {
	    chomp($scsi);
	    foreach my $regex (keys %regexs) {
		$pts += $regexs{$regex} if($scsi =~ /$regex/);
	    }
	}
    }

    # scan IDE devices
    my $glob = procfs_getmp().'/ide/hd*/model';
    foreach my $hd (glob $glob) {
	my @ide = read_file($hd);

	foreach my $ide (@ide) {
	    chomp($ide);
	    foreach my $regex (keys %regexs) {
		$pts += $regexs{$regex} if($ide =~ /$regex/);
	    }
	}
    }

    return $pts;
}

1;
