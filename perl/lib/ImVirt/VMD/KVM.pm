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

package ImVirt::VMD::KVM;

use strict;
use warnings;
use constant PRODUCT => '|KVM';

use ImVirt;
use ImVirt::Utils::cpuinfo;
use ImVirt::Utils::dmesg;
use ImVirt::Utils::kmods;
use ImVirt::Utils::pcidevs;
use ImVirt::Utils::dmidecode;
use ImVirt::Utils::dmesg;
use ImVirt::Utils::sysfs;
use ImVirt::Utils::procfs;
use ImVirt::Utils::helper;
use ImVirt::Utils::kmods;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    # Check dmidecode
    if(defined(my $spn = dmidecode_string('system-product-name'))) {
        if ($spn =~ /^(KVM|Bochs)/) {
            ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
        else {
            ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
    }
    if(defined(my $spn = dmidecode_string('bios-vendor'))) {
        if ($spn =~ /^(QEMU|Bochs)/) {
            ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
        else {
            ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
    }

    # Look for dmesg lines
    if(defined(my $m = dmesg_match(
        ' QEMUAPIC ' => IMV_PTS_NORMAL,
        'QEMU Virtual CPU' => IMV_PTS_NORMAL,
        'Booting paravirtualized kernel on KVM' => IMV_PTS_MAJOR,
        'kvm-clock' => IMV_PTS_MAJOR,
      ))) {
        if($m > 0) {
            ImVirt::inc_pts($dref, $m, IMV_VIRTUAL, PRODUCT);
        }
        else {
            ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
    }

    # Look for clock source
    if(defined(my $cs = sysfs_read('devices/system/clocksource/clocksource0/available_clocksource'))) {
        if($cs =~ /kvm/) {
            ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
        else {
            ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
    }

    # Check /proc/cpuinfo
    my %cpuinfo = cpuinfo_get();
    foreach my $cpu (keys %cpuinfo) {
	if(${$cpuinfo{$cpu}}{'model name'} =~ /QEMU Virtual CPU/) {
	    ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}
    }

    # Check /proc/bus/pci/devices
    my %pcidevs = pcidevs_get();
    foreach my $addr (keys %pcidevs) {
	if(${$pcidevs{$addr}}{'device'} =~ /Qumranet, Inc\. Virtio/) {
	    ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}
    }

   # Check helper output for hypervisor detection
    if(my $hvm = helper('hvm')) {
        if($hvm =~ /KVM/) {
            ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
    }

    # Look for a dmesg paravirtualization line
    if(defined(my $m = dmesg_match(
	'Booting paravirtualized kernel on KVM' => IMV_PTS_MAJOR,
     ))) {
	ImVirt::inc_pts($dref, $m, IMV_VIRTUAL, PRODUCT) if($m > 0);
    }

    # Look for virtio modules
    my $p = kmods_match_used(
	'^virtio(_(blk|pci|net|ballon|ring))?$' => IMV_PTS_MINOR,
    );
    if($p > 0) {
	ImVirt::inc_pts($dref, $p, IMV_VIRTUAL, PRODUCT);
    }
}

sub pres() {
    return (PRODUCT);
}

1;
