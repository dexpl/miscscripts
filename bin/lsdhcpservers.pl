#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

$, = shift // ': ';

my $nmcli_cmd = q(nmcli -f GENERAL.DEVICE,DHCP4.OPTION --terse device show);
my $dhcp_option = q(dhcp_server_identifier);
my $ifname;

foreach (`$nmcli_cmd`) {
    chomp;
    if ( my @chunk = split /:/ ) {
        if ( $chunk[0] eq 'GENERAL.DEVICE' ) {
            $ifname = $chunk[-1];
        } else {
            my ( $name, $value ) = split / = /, join ':',
              @chunk[ 1 .. $#chunk ];
            say $ifname, $value if $name eq $dhcp_option;
        }
    }
}
