use strict;
use warnings;
use String::Nysiis qw(nysiis);


while ( my $str = <> ) {
  chomp $str;
  print join("\t",nysiis($str),$str),"\n";
}
