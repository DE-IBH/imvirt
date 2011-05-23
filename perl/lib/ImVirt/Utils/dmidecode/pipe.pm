# ImVirt - I'm virtualized?
#
# $Id$
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2011 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt::Utils::dmidecode::pipe;

use strict;
use warnings;
use IO::Handle;
require Exporter;
our @ISA = qw(Exporter);

our $VERSION = '0.1';

my $dmidecode = '/usr/sbin/dmidecode';
my $devmem = '/dev/mem';

sub available() {
    return (-r $devmem && -x $dmidecode);
}

sub dmidecode_string($) {
    return dmidecode('-s', shift)
}
sub dmidecode_type($) {
    return dmidecode('-t', shift)
}

sub dmidecode() {
    return () unless (-r $devmem && -x $dmidecode);

    pipe(PARENT_RDR, CHILD_WTR);
    if(my $pid = fork()) {
	close(CHILD_WTR);
	my @res = <PARENT_RDR>;
	close(PARENT_RDR);

	my $res = join(' ', @res);

	return $res if($res);

	return undef;
    } else {
	die "Cannot fork: $!\n" unless defined($pid);
	
	close(PARENT_RDR);
	open(STDOUT, '>&CHILD_WTR') || die "Could not dup: $!\n";
	close(STDERR);

	exec($dmidecode, '-d', $devmem, @_);

	die("Cannot exec $dmidecode: $!\n");
    }
}

1;
