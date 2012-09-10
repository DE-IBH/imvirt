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

package ImVirt::VMD::Microsoft;

use strict;
use warnings;
use constant PRODUCT => '|Microsoft';
use constant HYPERV => 'Hyper-V';
use constant VIRTUALPC => 'VirtualPC';

use ImVirt;
use ImVirt::Utils::blkdev;
use ImVirt::Utils::dmidecode;
use ImVirt::Utils::dmesg;
use ImVirt::Utils::helper;
use ImVirt::Utils::pcidevs;
use ImVirt::Utils::procfs;
use ImVirt::Utils::kmods;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    if(defined(my $spn = dmidecode_string('system-product-name'))) {
	if ($spn =~ /^Virtual Machine/) {
	    ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}
	else {
	    ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}
    }

    my $p = blkdev_match(
	'Virtual HD' => IMV_PTS_NORMAL,
	'Virtual CD' => IMV_PTS_NORMAL,
    );
    if($p > 0) {
	ImVirt::inc_pts($dref, $p, IMV_VIRTUAL, PRODUCT);
    }
    else {
	ImVirt::dec_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT);
    }

    # Check helper output
    if(my $hlp = helper('hyperv')) {
	ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
    }

    # Check /proc/bus/pci/devices
    my %pcidevs = pcidevs_get();
    foreach my $addr (keys %pcidevs) {
	if(${$pcidevs{$addr}}{'device'} eq 'Hyper-V virtual VGA') {
	    ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT, HYPERV);
	}
	elsif(${$pcidevs{$addr}}{'device'} eq 'DECchip 21140 [FasterNet]') {
	    ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT);
	}
	elsif(${$pcidevs{$addr}}{'device'} eq 'Microsoft Corporation Device 0007') {
	    ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT, VIRTUALPC);
	}
    }

    # Check /proc/irq/7/hyperv
    ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT, HYPERV)
	if(procfs_isdir('irq/7/hyperv'));

    # Look for Hyper-V modules
    $p = kmods_match_used(
	'^hv_(vmbus|storvsc|netvsc|utils)$' => IMV_PTS_NORMAL,
    );
    if($p > 0) {
	ImVirt::inc_pts($dref, $p, IMV_VIRTUAL, PRODUCT);
    }
}

sub pres() {
    return (
	PRODUCT.HYPERV
    );
}

1;
