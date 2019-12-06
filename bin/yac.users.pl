#!/usr/bin/perl -l

use strict;
use utf8;
use warnings;

use Text::CSV qw( csv );

sub gettoken {
    return $ENV{'YAC_TOKEN'};
}

# takes hashref
# returns somewhat
sub adduser {
    my $token = gettoken;
    print $token;
    my $hash = shift;
    print $hash->{'password'};
}

my $src_file = @ARGV;
my $csv      = csv( in => $src_file, headers => "auto", auto_diag => 1 );

#print $_->{"last"} for (@$csv);
adduser( mkuser($_) ) for (@$csv);
