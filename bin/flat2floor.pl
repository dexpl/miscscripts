#!/usr/bin/env perl
#===============================================================================
#
#         FILE: flat2floor.pl
#
#        USAGE: ./flat2floor.pl floor_count flats_on_the_floor flat_number
#
#  DESCRIPTION: Дано: этажность дома и количество квартир на этаже.
# Требуется, зная номер квартиры, найти ее подъезд и этаж.
#
#      OPTIONS: floor_count - этажность дома
#               flats_on_the_floor - кол-во квартир на этаже
#               flat_number - номер искомой квартиры
#       AUTHOR: Vadim V. Raskhozhev
#      VERSION: 0.1
#      CREATED: 25.11.2022 09:27:01
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use open ':locale';

sub excess { my $div = int ${_[0]} / ${_[1]}; ($div, ${_[0]} - $div * ${_[1]}) }

# TODO Getopt
# $fof - кол-во квартир на этаже (flats on a floor)
# $flat_no - номер искомой квартиры
my ($floor_cnt, $fof, $flat_no) = @ARGV;
map { $_++ unless $_ } ($floor_cnt, $fof, $flat_no);
my ($hall_no, $hall_tail) = excess($flat_no, $floor_cnt * $fof);
$hall_no++ if $hall_tail;
my ($floor_no, $floor_tail) = excess($hall_tail, $fof);
$floor_no++ if $floor_tail;
printf "Подъезд: %d\nЭтаж: %d\n", $hall_no, ($floor_no) ? $floor_no : $floor_cnt;
