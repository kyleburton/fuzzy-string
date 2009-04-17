use strict;
use warnings;
use Text::Soundex qw(soundex);


while ( my $str = <> ) {
  chomp $str;
  print join("\t",soundex($str),$str),"\n";
}
