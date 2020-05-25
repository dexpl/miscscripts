#!/usr/bin/perl

use open ':locale';
use strict;
use warnings;
use utf8;

use Data::Dumper;
use Encode qw/encode decode/;
use Encode::IMAPUTF7;
use Net::IMAP::Client;
use Net::Netrc;
use Time::Piece;
use Time::Seconds;

$\ = "\n";
$, = ' ';
my %sconf = (
    'dexpl@ya.ru' => {
        server          => 'imap.yandex.com',
        ssl             => 1,
        ssl_verify_peer => 0,
    },
    'beru@shiptor.ru' => {
        server          => 'imap.yandex.com',
        ssl             => 1,
        ssl_verify_peer => 0,
    },
);

my $archive_prefix = 'Архив';

{
    # https://stackoverflow.com/a/2037520
    use I18N::Langinfo qw/langinfo CODESET/;
    @ARGV = map { decode langinfo(CODESET), $_ } @ARGV;
}

my $user = shift;
die "No user name given" . $\ unless $user;
die "No config found for ${user}" . $\ unless $sconf{$user};
my $mach = Net::Netrc->lookup( $sconf{$user}->{server}, $user );
die "No password found for ${user}" . $\ unless $mach;
my $pass = $mach->password;

#my $today = localtime;
#my $general_search_criteria =
#  { 'before' => "1-" . $today->monname . "-" . $today->year };
my $baseday                 = localtime() - 1 * ONE_DAY;
my $general_search_criteria = {
    'before' => join '-',
    ( $baseday->mday, $baseday->monname, $baseday->year )
};
print STDERR Dumper $general_search_criteria;

my $imap = Net::IMAP::Client->new(
    %{ $sconf{$user} },
    user => $user,
		pass => $pass,
) or die "Cannot connect to IMAP server" . $\;

$imap->login or die "Login failed: @{[$imap->last_error]}" . $\;

my %folders =
  map { print STDERR $_; decode( 'IMAP-UTF-7', $_ ) => $_ } $imap->folders;

my $folder     = @ARGV ? join $imap->separator, @ARGV : 'INBOX';
my $iu7_folder = encode 'IMAP-UTF-7', $folder;

if ( $imap->select($iu7_folder) ) {
    if ( my $msg_ids = $imap->search($general_search_criteria) ) {
        my %to_archive;
        foreach ( @{ $imap->get_summaries( $msg_ids, 'from' ) // [] } ) {
            my $msg_date =
              Time::Piece->strptime( ( split ' ', $_->internaldate )[0],
                '%d-%b-%Y' );
            my $archive_path = $archive_prefix
              . $msg_date->strftime( join $imap->separator,
                ( '', "%Y", "%m", "%d" ) );
            print STDERR $archive_path;
            push @{ $to_archive{$archive_path} }, $_->uid;
            local $, = ' ';
            print( $_->uid, $_->internaldate );
        }
        foreach ( keys %to_archive ) {
            my $iu7_archive_folder = $folders{$_};
            unless ($iu7_archive_folder) {
                $iu7_archive_folder = encode 'IMAP-UTF-7', $_;
                if ( $imap->create_folder($iu7_archive_folder) ) {
                    $folders{$_} = $iu7_archive_folder;
                } else {
                    print STDERR $imap->last_error;
                    next;
                }
            }
            if ( $imap->copy( $to_archive{$_}, $iu7_archive_folder ) ) {
                $imap->add_flags( $to_archive{$_}, '\\Deleted' ) or print STDERR $imap->last_error;
            } else {
                print STDERR $imap->last_error;
            }
        }
        $imap->expunge;
    }
} else {
    print STDERR $imap->last_error;
}
$imap->logout or die "Logout failed: @{[$imap->last_error]}" . $\;
