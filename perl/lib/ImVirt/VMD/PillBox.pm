# ImVirt - I'm virtualized?
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt::VMD::PillBox;

use strict;
use warnings;

use ImVirt;
use ImVirt::Utils::helper;

ImVirt::register_vmd(__PACKAGE__);

#
# The detection heuristic is based on:
#
# [1] "Red Pill... or how to detect VMM using (almost) one CPU instruction"
#      Joanna Rutkowska
#      http://invisiblethings.org/papers/redpill.html
#
# [2] "Detecting the Presence of Virtual Machines Using the Local Data Table"
#      Danny Quist, Val Smith
#      http://www.offensivecomputing.net/files/active/0/vm.pdf
#
# [3] "Methods for Virtual Machine Detection"
#      Alfredo Andrés Omella
#      http://www.s21sec.com/descargas/vmware-eng.pdf
#
# [4] "ScoopyNG - The VMware detection tool"
#      Tobias Klein
#      http://www.trapkit.de/research/vmm/scoopyng/index.html

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    if (my $pb = helper('pillbox')) {
	my %pb = split(/,/, $pb);

	# pillbox was bound to one cpu - if we got different
	# IDTR/GDTR values, we are virtualized (so the HVM
	# did schedule us on a different physical cpus) or
	# our cpu has been taken offline.
	ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL)
	 if (exists($pb{'idt2'}) || exists($pb{'gdt2'}));

	ImVirt::inc_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL)
	 if ((($pb{'idt'} & 0xffff) > 0xd000) &&
	     (($pb{'gdt'} & 0xffff) > 0xd000)); # [1]

	ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL)
	 if ($pb{'ldt'} > 0); # [2]

	ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, '|VMware')
	 if ($pb{'tr'} == 0x4000); # [3]

	ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, '|VMware')
	 if ($pb{'idt'} >> 24 == 0xff); # [4]

	ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, '|VMware')
	 if ($pb{'gdt'} >> 24 == 0xff); # [4]
    }
}

sub pres() {
    return ('|VMware');
}

1;
