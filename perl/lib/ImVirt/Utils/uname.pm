# ImVirt - I'm virtualized?
#
# $Id$
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

package ImVirt::Utils::uname;

use strict;
use warnings;
use Data::Dumper;
use POSIX;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    uname
);

our $VERSION = '0.1';

my @uname = POSIX::uname();
my %uname = (
    sysname => shift(@uname),
    nodename => shift(@uname),
    release => shift(@uname),
    version => shift(@uname),
    machine => shift(@uname),
);
ImVirt::debug(__PACKAGE__, Dumper(\%uname));

sub uname() {
    return %uname;
}

1;
