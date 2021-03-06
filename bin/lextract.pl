#!/usr/bin/perl -lw

use strict;

use HTML::TreeBuilder;
use URI;
use URI::Heuristic qw(uf_uristr);

my ( $url, $pat ) = @ARGV;
die "Missing URL$/" unless $url;
$url = uf_uristr $url;
$pat //= '.';
$pat = qr/$pat/;
print @$_[0] foreach grep {
    @$_[0] = URI->new_abs( @$_[0], $url );
    @$_[0] =~ /$pat/;
} @{ HTML::TreeBuilder->new_from_url($url)->extract_links('a') };

__END__

=head1 NAME

lextract - extract links from a given URL

=head1 SYNOPSIS

=over 12

=item B<lextract>

B<url>
[I<regex>]

=back

=head1 DESCRIPTION

To be written

=head1 EXAMPLES

lextract http://www.exampdd.ru/files.htm Neva2016
