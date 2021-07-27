#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

$, = shift // ': ';
my ( $ifname, %dhcp );

# TODO use `nmcli -g all device show` since this won't work on CentOS 7
foreach (`nmcli -g UUID connection show --active`) {
    foreach (`nmcli -g GENERAL.DEVICES,DHCP4 connection show uuid $_`) {
        chomp;
        if (s,^DHCP4:,,) {
            $dhcp{$ifname} = (
                split / = /,
                ( grep { /dhcp_server_identifier/ } split / \| / )[0] // ''
            )[-1];
        } else {
            $ifname = $_;
        }
    }
}
say $_, $dhcp{$_} foreach grep { $dhcp{$_} } sort keys %dhcp;
