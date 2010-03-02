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

package ImVirt::VMD::Xen;

use strict;
use warnings;
use constant PRODUCT => 'Xen';

use ImVirt;
use ImVirt::Utils::dmidecode;
use ImVirt::Utils::dmesg;
use ImVirt::Utils::procfs;
use ImVirt::Utils::sysfs;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    # Check dmidecode
    if(defined(my $spn = dmidecode_string('bios-vendor'))) {
	if ($spn =~ /^Xen/) {
	    ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}
	else {
	    ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}
    }

    # Look for paravirutalized oldstyle Xen
    if(procfs_isdir('xen')) {
	ImVirt::inc_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT, 'PV');
    }
    # Look for paravirutalized newstyle Xen
    elsif(defined(my $cs = sysfs_read('devices/system/clocksource/clocksource0/available_clocksource'))) {
	if($cs =~ /xen/) {
	    ImVirt::inc_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT, 'PV');
	}
	else {
	    ImVirt::dec_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT, 'PV');
	}
    }

    # Look for dmesg lines
    if(defined(my $m = dmesg_match(
	'Hypervisor signature: xen' => IMV_PTS_NORMAL,
	'Xen virtual console successfully installed' => IMV_PTS_NORMAL,
	'Xen reported:' => IMV_PTS_NORMAL,
	'Xen: \d+ - \d+' => IMV_PTS_NORMAL,
	'xen-vbd: registered block device' => IMV_PTS_NORMAL,
	'ACPI: RSDP \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
	'ACPI: XSDT \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
	'ACPI: FADT \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
	'ACPI: MADT \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
	'ACPI: HPET \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
	'ACPI: SSDT \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
	'ACPI: DSDT \(v\d+\s+Xen ' => IMV_PTS_NORMAL,
      ))) {
	if($m > 0) {
	    ImVirt::inc_pts($dref, $m, IMV_VIRTUAL, PRODUCT);
	}
	else {
	    ImVirt::dec_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
	}

	# Paravirtualized?
	if(defined(my $m = dmesg_match(
	    'Booting paravirtualized kernel on Xen' => IMV_PTS_MAJOR,
	  ))) {
	    if($m > 0) {
		ImVirt::inc_pts($dref, $m, IMV_VIRTUAL, PRODUCT, 'PV');
	    }
	    else {
		ImVirt::dec_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT, 'PV');
	    }
	}
    }

    # Xen PV does not have ide/scsi drives
    if(procfs_isdir('ide') || procfs_isdir('scsi')) {
	ImVirt::dec_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT, 'PV');
    }
    else {
	ImVirt::dec_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT, 'HVM');
    }
}

1;
