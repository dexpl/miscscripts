#!/usr/bin/perl -w

use strict;

sub fib {
    my $i = int( shift // 0 );
    $i >= 2 ? fib( $i - 1 ) + fib( $i - 2 ) : $i;
}

printf "fib(%2d) = %10d$/", $_, fib($_) foreach ( 0 .. int( shift // 0 ) )
