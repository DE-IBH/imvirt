# ImVirt - I'm virtualized?
#
# $Id$
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2011 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt::VMD::lguest;

use strict;
use warnings;
use constant PRODUCT => '|lguest';

use ImVirt;
use ImVirt::Utils::kmods;
use ImVirt::Utils::dmesg;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    # Look for a dmesg paravirtualization line
    if(defined(my $m = dmesg_match(
	'Booting paravirtualized kernel on lguest' => IMV_PTS_MAJOR,
     ))) {
	ImVirt::inc_pts($dref, $m, IMV_VIRTUAL, PRODUCT) if($m > 0);
    }

    # Look for virtio modules
    my $p = kmods_match(
	'^virtio_(blk|pci|net|ballon)$' => IMV_PTS_MINOR,
    );
    if($p > 0) {
	ImVirt::inc_pts($dref, $p, IMV_VIRTUAL, PRODUCT);
    }
}

sub pres() {
    return (PRODUCT);
}

1;
