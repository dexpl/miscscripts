#!/bin/perl

use strict;
use warnings;
use utf8;

use JSON;
use MIME::Base64;

# TODO getopt
my $hv_name = shift;
my $vm_name = shift;

my $hv_url = sprintf( 'qemu+ssh://%s/system', $hv_name );
my $cmd = to_json(
    {
        "execute" => "guest-exec",
        "arguments" =>
          { "path" => shift, "arg" => \@ARGV, "capture-output" => JSON::true }
    }
);
my $result =
  `virsh -c ${hv_url} qemu-agent-command --cmd '$cmd' --domain $vm_name`;
my $pid = decode_json($result)->{'return'}->{'pid'};
$cmd = to_json(
    { "execute" => "guest-exec-status", "arguments" => { "pid" => $pid } } );
$result =
  `virsh -c ${hv_url} qemu-agent-command --cmd '$cmd' --domain $vm_name`;
print decode_base64( decode_json($result)->{'return'}->{'out-data'} );
