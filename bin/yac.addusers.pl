#!/usr/bin/perl -l

use strict;
use warnings;
use utf8;

use File::Which;
use HTTP::Request;
use JSON;
use Lingua::Translit;
use LWP::UserAgent;
use String::Random;
use Text::CSV qw( csv );

my @in_headers  = qw(last  first  middle);
my @out_headers = ( @in_headers, qw( nickname password response) );

my $base_url = "https://api.directory.yandex.net/v6";
my $ua       = LWP::UserAgent->new();

# see Lingua::Translit::Tables
use constant TRANSLIT_SCHEME => "BGN/PCGN RUS Standard";

my $tr = new Lingua::Translit(TRANSLIT_SCHEME);

sub mknickname {
    my ( $first, $last, $middle ) = @_;
    my $nickname = lc(
            substr( $first, 0, 1 )
          . ( ($middle) ? '.' . substr( $middle, 0, 1 ) : '' )
          . ".$last" );
    $nickname = $tr->translit($nickname);
    $nickname =~ tr,',i,;
    return $nickname;
}

# returns string
sub mkpasswd {
    my $pw;
    chomp( $pw = `pwqgen` )        if ( !$pw && which('pwqgen') );
    chomp( $pw = `apg -a 0 -n 1` ) if ( !$pw && which('apg') );
    $pw = String::Random->new()->randpattern('Cssss!Cssss!Cssss') unless $pw;
}

sub gettoken {
    return $ENV{'YAC_TOKEN'};
}

sub adduser {
    my $token  = gettoken;
    my $header = [
        'Content-Type'  => 'application/json',
        'Authorization' => "OAuth $token"
    ];

    $_{'department_id'} //= 1;
    $_{'nickname'}      //= mknickname( $_{'first'}, $_{'last'}, $_{'middle'} );
    for my $key (@in_headers) {
        $_{'name'}{$key} = $_{$key};
        delete $_{$key};
    }
    $_{'password'} //= mkpasswd();
    my $body = encode_json( \%_ );

    my $request =
      HTTP::Request->new( 'POST', "$base_url/users/", $header, $body );
    my $response = $ua->request($request);
    $_{'response'} = $response->status_line;
}

my $src_file = shift // '-';
my $dst_file = shift // $src_file;
$src_file = *STDIN  if $src_file eq '-';
$dst_file = *STDOUT if $dst_file eq '-';
unless ( -w $dst_file ) {
    print STDERR "File $dst_file is not writable, writing to STDOUT";
    $dst_file = *STDOUT;
}

my $csv = csv(
    auto_diag => 1,
    encoding  => 'utf8',
    headers   => [@in_headers],
    in        => $src_file,
    on_in     => \&adduser,
    sep       => ' ',
);

csv(
    auto_diag  => 1,
    encoding   => 'utf8',
    headers    => [@out_headers],
    in         => $csv,
    out        => $dst_file,
    before_out => sub {
        for my $key (@in_headers) {
            $_{$key} = $_{'name'}{$key};
            delete $_{'name'}{$key};
        }
    },
);