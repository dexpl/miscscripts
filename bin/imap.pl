#!/usr/bin/perl

use open ':locale';
use strict;
use warnings;
use utf8;

use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin";    # TODO remove this from release!
use Encode qw/encode decode/;
use Encode::IMAPUTF7;
use Net::IMAP::Client;
use Time::Piece;

$\ = "\n";
$, = ' ';
my %sconf = (
    'dexpl@ya.ru' => {
        server => 'imap.yandex.com',
        pass   => 'nofate_yandex',
        ssl    => 1,
    },
    'iamdexpl@gmail.com' => {
        server => 'imap.googlemail.com',
        pass   => 'nofate google',
        ssl    => 1,
    },
    'beru@shiptor.ru' => {
        server => 'imap.yandex.com',
        pass   => 'smack6avenue7Sign',
        ssl    => 1,
    },
);

my $archive_prefix = 'Архив';

my $today = localtime;
my $general_search_criteria =
  { 'before' => "1-" . $today->monname . "-" . $today->year };

{
    # https://stackoverflow.com/a/2037520
    use I18N::Langinfo qw/langinfo CODESET/;
    @ARGV = map { decode langinfo(CODESET), $_ } @ARGV;
}

my $user = shift;
die "No user name given" . $\ unless $user;
die "No config found for ${user}" . $\ unless $sconf{$user};

my $imap = Net::IMAP::Client->new(
    %{ $sconf{$user} },
    user            => $user,
    ssl_verify_peer => 0
) or die "Cannot connect to IMAP server" . $\;

$imap->login or die "Login failed: @{[$imap->last_error]}" . $\;

my %folders = map { decode( 'IMAP-UTF-7', $_ ) => $_ } $imap->folders;

my $folder     = @ARGV ? join $imap->separator, @ARGV : 'INBOX';
my $iu7_folder = encode 'IMAP-UTF-7', $folder;

if ( $imap->examine($iu7_folder) ) {
    if ( my $msg_ids = $imap->search($general_search_criteria) ) {
        my %to_archive;
        foreach ( @{ $imap->get_summaries( $msg_ids, 'from' ) } ) {
            my $msg_date =
              Time::Piece->strptime( ( split( ' ', $_->internaldate ) )[0],
                '%d-%b-%Y' );
            my $archive_path =
              $archive_prefix
              . $msg_date->strftime(
                $imap->separator . "%Y" . $imap->separator . "%m" );
            push @{ $to_archive{$archive_path} }, $_->uid;
        }
        foreach ( keys %to_archive ) {
            my $iu7_archive_folder = $folders{$_};
            unless ($iu7_archive_folder) {
                $iu7_archive_folder = encode 'IMAP-UTF-7', $_;
                unless ( $imap->create_folder($iu7_archive_folder) ) {
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
