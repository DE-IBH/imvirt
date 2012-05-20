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

package ImVirt::Utils::run;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    run_exec
);

our $VERSION = '0.1';

eval 'use File::Which;';
my $nowhich = $@;

sub run_exec(@) {
    my $cmd = shift;
    my $run = ($nowhich ne '' ? $cmd : which($cmd));
    if(defined($run)) {
	exec($run, @_);
    }
    else {
	ImVirt::debug(__PACKAGE__, "binary $cmd not found");
    }
}

1;
