#!/usr/bin/perl -l

use strict;
use warnings;

use Archive::Zip;

my $data_size = shift // 1020;

binmode STDIN;

if (read(STDIN, my $data, $data_size) == $data_size) {
	my $crc = Archive::Zip::computeCRC32($data);
	print "Data size: $data_size";
	print "CRC: $crc";
	printf "Hex: 0x%08x\n", $crc;
	printf "Inv hex: 0x%08x\n", 0xFFFFFFFF - $crc;
	printf "0x%08x\n", unpack "V", $crc;
} else {
	die "Cannot read $data_size bytes";
}
