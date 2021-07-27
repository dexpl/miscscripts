#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use File::Spec;
my $plugin_name = $1
  if ( File::Spec->splitpath($0) )[-1] =~ /toggle_([a-z]+)_panel/;
$plugin_name = shift       unless $plugin_name;
die 'No plugin name given' unless $plugin_name;
foreach (grep { /plugin-ids$/ } `xfconf-query -c xfce4-panel -l`) {
    my ( $flag, $cnt, $plugin_id ) = (0) x 0;
    foreach (`xfconf-query -c xfce4-panel -p $_`) {
        $plugin_id = $_;
        $cnt++  if $flag;
        $flag++ if /^$/;
    }
    next unless $cnt == 1;
    next
      unless `xfconf-query -c xfce4-panel -p /plugins/plugin-${plugin_id}` =~
      /$plugin_name/;
    my $panel = ( File::Spec->splitpath($_) )[1];
    chomp $panel;
    my $state_cmd =
      "xfconf-query -c xfce4-panel -n -p ${panel}autohide-behavior -t int";
    my $state = `$state_cmd`;
    `$state_cmd -s @{[abs(2 - $state)]}`;
}
