#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

$, = shift // ': ';
my ( $ifname, $item, $flag, @data, %dhcp );

# TODO use `nmcli -g all device show` since this won't work on CentOS 7
foreach (`nmcli -g all device show`) {
    chomp;
	$item = {} unless $item;
	if (my @chunk = split ':') {
		$item->{$chunk[0]} = join ':', @chunk[1..$#chunk];
		$flag++ if $chunk[0] eq 'DHCP4';
	} else {
		push @data, $item if $flag;
		($item, $flag) = undef;
	}
}
use Data::Dumper;
print Dumper @data;
say $_, $dhcp{$_} foreach sort keys %dhcp;
__END__
    if (s,^DHCP4:,,) {
        $dhcp{$ifname} =
          ( split / = /, ( grep { /dhcp_server_identifier/ } split / \| / )[0] )
          [-1];
    } else {
        $ifname = $_;
    }
}
say $_, $dhcp{$_} foreach sort keys %dhcp;
