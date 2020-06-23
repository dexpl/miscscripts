#!/usr/bin/perl -w

sub divisible {
    my ( $divident, $denominator ) = @_;
    $divident % $denominator == 0;
}

sub is_leap {
    my $year = shift;
    divisible( $year, 100 ) ? divisible( $year, 400 ) : divisible( $year, 4 );
}

@years = @ARGV ? @ARGV : ( 1900 + (localtime)[5] );
printf "%-d is a %sleap year$/", $_, is_leap($_) ? '' : 'non-' foreach @years;
