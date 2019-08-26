#!/usr/bin/perl -lw

sub mean {
	return undef unless @_;
	$rslt += $_ foreach @_;
	$rslt / @_;
}

sub median {
	return undef unless @_;
	my @data = @_;
	return $data[@data / 2] if @data % 2;
	@data = sort { $a <=> $b } @_;
	mean($data[@data / 2], $data[@data / 2 - 1]);
}

sub std_dev {
	return undef unless @_;
	$avg = mean(@_);
	$sq_dev_sum += ($avg - $_) ** 2;
	sqrt($sq_dev_sum / (@_ - 1));
}

print "Data is @ARGV";
print "Mean is " . mean(@ARGV);
print "Median is " . median(@ARGV);
print "Std. dev. is " . std_dev(@ARGV);
