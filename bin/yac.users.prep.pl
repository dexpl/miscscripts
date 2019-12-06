#!/usr/bin/perl -l

# Преобразуем список вида
# Фамилия1 Имя1 Отчество1
# Фамилия2 Имя2 Отчество2
# ...
# в CSV-файл вида
# nickname,first,last,password
# i.familiya1,Имя1,Фамилия1,randompw1
# i.familiya2,Имя2,Фамилия2,randompw2
# ...
# Здесь randompwX — результат работы pwqgen(1) либо perl-модуля String::Random.

use strict;
use utf8;
use warnings;

use File::Which;
use Lingua::Translit;
use String::Random;
use Text::CSV qw( csv );

# see Lingua::Translit::Tables
use constant TRANSLIT_SCHEME => "BGN/PCGN RUS Standard";

my $tr = new Lingua::Translit(TRANSLIT_SCHEME);

# returns string
sub mkpasswd {
    chomp( my $pw = `pwqgen` ) if which('pwqgen');
    return $pw ? $pw : String::Random->new()->randpattern('Cssss!Cssss!Cssss');
}

my ( $src_file, $dst_file ) = @ARGV;
my $csv = csv(
    auto_diag => 1,
    headers   => [qw(last  first  middle)],
    in        => $src_file eq '-' ? *STDIN : $src_file,
    sep_char  => ' ',
);

csv(
    in         => $csv,
    out        => $dst_file eq '-' ? *STDOUT : $src_file,
    encoding   => 'utf8',
    headers    => [qw(nickname first last password)],
    before_out => sub {
        (
            $_{'nickname'} = $tr->translit(
                lc( substr( $_{'first'}, 0, 1 ) . '.' . $_{'last'} )
            )
        ) =~ tr,',i,;
        $_{'password'} = mkpasswd();
        undef $_{'middle'};
    },
);
