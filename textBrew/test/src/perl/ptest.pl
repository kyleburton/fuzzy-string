package _TMP_SCRIPT;
use strict;
use warnings;
use lib 'src/perl';
use Text::Brew qw(distance);
$|++;

$Text::Brew::DEBUG = 1;
#pbrew('BRYN','RESTAURANT');
pbrew('BRYN MAWR PIZZA II','BEIJING CHINESE RESTAURANT');

sub pbrew {
  my($a,$b) = @_;
  my $edits = distance($a,$b,{-cost=>[0,.1,15,1],-output=>'edits'});
  print join(",",map { substr $_,0,1 } @$edits),"\n";
}


# use Inline;
# Inline->init;
# use Inline C => << 'E_SOURCE';

# #include "brew.h"

# SV*
# cdistance( SV* left, SV* right ) {
#   AV* result = newAV();)
#   if ( !SvOK(left) || ! SvOk(right) ) {
#     return result;
#   }

#   return result;
# }

# #include "brew.c"

# E_SOURCE

1;
