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

package ImVirt::VMD::UML;

use strict;
use warnings;
use constant PRODUCT => 'UML';

use ImVirt;
use ImVirt::Utils::cpuinfo;
use ImVirt::Utils::dmesg;

ImVirt::register_vmd(__PACKAGE__);

sub detect() {
    ImVirt::debug(__PACKAGE__, 'detect()');

    # Check /proc/cpuinfo
    my %cpuinfo = cpuinfo_get();
    foreach my $cpu (keys %cpuinfo) {
	if(${$cpuinfo{$cpu}}{'vendor_id'} eq 'User Mode Linux') {
	    ImVirt::inc_pts(IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}

	if(${$cpuinfo{$cpu}}{'model name'} eq 'UML') {
	    ImVirt::inc_pts(IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}

	if(${$cpuinfo{$cpu}}{'model'} eq 'skas') {
	    ImVirt::inc_pts(IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}

	if(${$cpuinfo{$cpu}}{'host'}) {
	    ImVirt::inc_pts(IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT);
	}
    }

    # Look for dmesg lines
    if(defined(my $m = dmesg_match('UML Watchdog Timer' => IMV_PTS_NORMAL))) {
	if($m > 0) {
	    ImVirt::inc_pts($m, IMV_VIRTUAL, PRODUCT);
	}
	else {
	    ImVirt::dec_pts(IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT);
	}
    }
}

1;
