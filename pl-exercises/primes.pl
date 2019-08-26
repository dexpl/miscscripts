#!/usr/bin/perl -lw
my ( @primes, $compound );
my $maxprimes = shift // 20;
for ( my $i = 2 ; @primes < $maxprimes ; $i++ ) {
    foreach (@primes) {
        $compound = ( $i % $_ == 0 );
        last if $compound;
    }
    push @primes, $i unless $compound;
}
print foreach @primes;
