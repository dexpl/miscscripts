#!/usr/bin/perl -lw

use strict;

use LWP::Simple;
use XML::XPath;

die "Usage: $0 abbr [abbr]...$/" unless @ARGV;

my $url   = 'http://acronyms.silmaril.ie/cgi-bin/xaa?';
my $found = '/acronym/found';
my $acro  = "${found}/acro";
$found = sprintf 'string(%s/@n)', $found;
my @attrs = ( 'expan', 'comment' );
foreach (@ARGV) {
    my $xml = get("$url$_");
    die "Error while talking to acronym server$/" unless defined $xml;
    my $xpath   = XML::XPath->new( xml => $xml );
    my $found_n = $xpath->findvalue($found);
    if ($found_n) {
        print "$_ is";
        foreach ( $xpath->findnodes($acro) ) {
            my $node = $_;
            my @val =
              map { $node->findvalue($_) } @attrs;
            $val[-1] = "/* ${val[-1]} */" if $val[-1];
            print "\t@val";
        }
    } else {
        print "$_ was not found";
    }
}
