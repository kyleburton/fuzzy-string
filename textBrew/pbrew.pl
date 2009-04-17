package _TMP_SCRIPT;
use strict;
use warnings;
$|++;

use Text::Brew qw(distance);
use Data::Dumper;


{my %map = (
            INITIAL => '*',
            MATCH   => 'M',
            DEL     => 'D',
            SUBST   => 'S',
            INS     => 'I',
           );
 my $costVector = [0,.1,15,1];
 my $brewOpts = {-cost=>$costVector,-output=>'both'};
sub runBrew {
  my($a,$b,$score) = @_;
  my($dist,$edits) = distance($a,$b,$brewOpts);
  print "$a\t$b\t$dist\t",join(",",map { $map{$_} } @$edits),"\t$score\n";
}}


my @lines = `cat data/test-cases.tab`;
shift @lines;
chomp @lines;
print join("\t",qw(LEFT RIGHT DISTANCE EDIT_PATH ORG_SIM_SCORE)),"\n";
foreach my $line (@lines) {
  my($left,$right,$score) = split /\t/, $line;
  runBrew($left,$right,$score);
}

#my($a,$b) = ('BRYN','RESTAURANT');
#runBrew($a,$b);
#runBrew($b,$a);


1;
