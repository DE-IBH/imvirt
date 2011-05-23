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

package ImVirt::Utils::dmidecode::kernel;

use strict;
use warnings;
use IO::Handle;
use ImVirt::Utils::sysfs;

require Exporter;
our @ISA = qw(Exporter);

our $VERSION = '0.1';

my $sysfs_relp = 'class/dmi/id';
my $sysfs_absp = join('/', sysfs_getmp(), $sysfs_relp);

sub available() {
    return sysfs_isdir('class/dmi/id');
}

sub dmidecode_string($) {
    open(HR, '<', join('/', $sysfs_absp, shift));
    my @res = <HR>;
    close(HR);

    my $res = join(' ', @res);

    return $res if($res);

    return undef;
}

sub dmidecode_type($) {
    my @res;

    foreach my $string (glob join('/', $sysfs_absp, shift."-*")) {
	push(@res, dmidecode_string($string));
    }

    return $res if($res);

    return undef;
}

1;
