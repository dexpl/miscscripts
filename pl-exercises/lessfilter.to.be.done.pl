#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use File::LibMagic;

my %cmds = ( 'text/plain' => 'enconv <', 'audio/mpeg' => 'midentify' );

my $filename = shift;
my $mimetype =
  File::LibMagic->new->info_from_filename($filename)->{'mime_type'};
print foreach `$cmds{$mimetype} "$filename"`;
