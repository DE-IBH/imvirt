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

package ImVirt::VMD::Generic;

use strict;
use warnings;

use ImVirt;
use ImVirt::Utils::cpuinfo;
use ImVirt::Utils::procfs;

ImVirt::register_vmd(__PACKAGE__);

sub detect() {
    ImVirt::debug(__PACKAGE__, 'detect()');

    if(defined(my $f = cpuinfo_hasflags(
	'vmx' => IMV_PTS_NORMAL,
	'svm' => IMV_PTS_NORMAL,
      ))) {
	if($f > 0) {
	    ImVirt::inc_pts($f, IMV_PHYSICAL);
	}
    }
}

1;
