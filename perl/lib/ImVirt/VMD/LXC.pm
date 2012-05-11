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

package ImVirt::VMD::LXC;

use strict;
use warnings;
use constant PRODUCT => '|LXC';

use ImVirt;
use ImVirt::Utils::sysfs;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    # Check init's control group data
    if(defined(my $cg = procfs_read('/proc/1/cgroup'))) {
        if($cg =~ /^\d+:[^:]+:/.+$/) {
            ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
        else {
            ImVirt::dec_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT);
        }
    }

    # Check init's environment for LXC
    if(defined(my $env = procfs_read('/proc/1/environ'))) {
        if($env =~ /lxc/i) {
            ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
        }
        else {
            ImVirt::dec_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT);
        }
    }
}

sub pres() {
    return (PRODUCT);
}

1;
