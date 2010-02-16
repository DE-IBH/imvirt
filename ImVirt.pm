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

package ImVirt;

use strict;
use warnings;
use constant {
    KV_POINTS	=> 'prop',
    KV_SUBPRODS	=> 'prods',

    IMV_PHYSICAL	=> 'PM',
    IMV_VIRTUAL		=> 'VM',

    IMV_PTS_MINOR	=> 1,
    IMV_PTS_NORMAL	=> 3,
    IMV_PTS_MAJOR	=> 6,
    IMV_PTS_DRASTIC	=> 12,
};

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    detect_vmd
    dump_vmd
    IMV_PHYSICAL
    IMV_VIRTUAL
    IMV_PTS_MINOR
    IMV_PTS_MAJOR
    IMV_PTS_DRASTIC
);

our $VERSION = '0.4.0';

my @vmds = ();
my %detected;

sub register_vmd($) {
    my $vmd = shift || return;

    push(@vmds, $vmd);
}

sub detect_vmd() {
    %detected = ();

    foreach my $vmd (@vmds) {
	eval "${vmd}::detect();";
    }
}

sub inc_pts($@) {
    my $prop = shift;

    _change_pts($prop, \%detected, @_);
}

sub dec_pts($@) {
    my $prop = shift;

    _change_pts(-$prop, \%detected, @_);
}

sub _change_pts($\%@) {
    my $prop = shift;
    my $ref = shift;
    my $key = shift;

    my $href = ${$ref}{$key};
    unless($href) {
        $href = ${$ref}{$key} = {KV_POINTS => 0, KV_SUBPRODS => {}};
    }

    if($#_ != -1) {
	&_change_pts($prop, ${$href}{KV_SUBPRODS}, @_);
    }
    else {
	${$href}{KV_POINTS} += $prop;
    }
}

sub dump_vmd() {
    _dump_vmd('', \%detected);
}

sub _dump_vmd($\%) {
    my $ident = shift;
    my $detected = shift;

    foreach my $prod (keys %{$detected}) {
	printf "$ident+ [%3d] %s\n", ${${$detected}{$prod}}{KV_POINTS}, $prod;
	&_dump_vmd("$ident\t", ${${$detected}{$prod}}{KV_SUBPRODS});
    }
}

1;
