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

# TODO 'before' => '1-${curMonth - 1}-${curYear}'
my $general_search_criteria = 'ALL';
$general_search_criteria = { 'before' => '1-Jun-2017' };
$general_search_criteria = { 'before' => '3-May-2017' };
#$general_search_criteria = 'ALL';

{
    # https://stackoverflow.com/a/2037520
    use I18N::Langinfo qw/langinfo CODESET/;
    @ARGV = map { decode langinfo(CODESET), $_ } @ARGV;
}

my $user = shift;
die "No user name given${\}" unless $user;
die "No config found for ${user}${\}" unless $sconf{$user};

my %conf = %{ $sconf{$user} };
my $imap = Net::IMAP::Client->new(
    %conf,
    user            => $user,
    ssl_verify_peer => 0
) or die "Cannot connect to IMAP server${\}";

#print foreach @{$imap->capability};
$imap->login or die "Login failed: @{[$imap->last_error]}${\}";
print decode 'IMAP-UTF-7', $_ foreach @{ $imap->folders };
print $imap->separator;
print 'Got SORT' if $imap->capability(qr/sort/i);
my $folder = @ARGV ? join $imap->separator, @ARGV : 'INBOX';
$folder = @ARGV ? join $imap->separator, @ARGV : $imap->separator;
my $iu7folder = encode 'IMAP-UTF-7', $folder;
print $folder;

if ( $imap->examine($iu7folder) ) {
    print Dumper $imap->{FOLDERS}{$iu7folder};
    if ( my $msg_ids = $imap->search($general_search_criteria) ) {
        my @msg_ids = @$msg_ids;
        print scalar @msg_ids;
				print Dumper $imap->get_summaries($msg_ids);
    }
} else {
    print STDERR $imap->last_error;
}
$imap->logout or die "Logout failed: @{[$imap->last_error]}${\}";
