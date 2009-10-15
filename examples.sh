for name in "De Morgen" "Di Morgen" "D’Morgun" "Demorgyn" "De Murgen" "Dy Moregan" "Dy Murgan" "Da Morgan" "Da Myrgn"; do
  echo "$(bin/fuzzy.rb meta "$name") $name"
done

exit

# Da Myrgn, Demorgyn => DAGN
# Dy Moregan => DNARAGAN
# Da Morgan, De Morgen, De Murgen, Di Morgen, Dy Murgan => DNARGAN
# D’Morgun => NARGAN
#
# TMRJTMRK   De Morgen, De Murgen, Demorgyn, Di Morgen
# TMRK       Da Morgan, Dy Moregan, Dy Murgan, D’Morgun
# TMRNTMRK   Da Myrgn

bin/fuzzy.rb find burton
bin/fuzzy.rb find soundex burton
bin/fuzzy.rb find nysiis burton
bin/fuzzy.rb find meta burton
bin/fuzzy.rb find edist burton
bin/fuzzy.rb find -t 0.70 edist burton
bin/fuzzy.rb -t 0.70 find edist burton
bin/fuzzy.rb -t 0.65 find edist burton
bin/fuzzy.rb -h -t 0.65 find edist burton
bin/fuzzy.rb brew foo fah
bin/fuzzy.rb -s typo_scores brew foo fah
bin/fuzzy.rb -s typo brew foo fah
bin/fuzzy.rb -s edist brew foo fah
bin/fuzzy.rb -s edis brew foo fah
bin/fuzzy.rb -s edist brew foo fah
bin/fuzzy.rb -s abbrev brew foo fah
bin/fuzzy.rb -s typo brew foo fah
bin/fuzzy.rb brew foo fah
bin/fuzzy.rb find brew burton
bin/fuzzy.rb --help
bin/fuzzy.rb -b '{:initial=>0,:match=>0,:insert=>0.1,:delete=>5,:subst=>5,:transpose=>2}' brew burton barton
bin/fuzzy.rb -b '{:initial=>0,:match=>0,:insert=>0.1,:delete=>1,:subst=>5,:transpose=>2}' brew burton barton
bin/fuzzy.rb -b '{:initial=>0,:match=>0,:insert=>1,:delete=>1,:subst=>2,:transpose=>0.1}' brew burton bruton
bin/fuzzy.rb -b '{:initial=>0,:match=>0,:insert=>1,:delete=>1,:subst=>2,:transpose=>0.1}' edist burton bruton
bin/fuzzy.rb -b '{:initial=>0,:match=>0,:insert=>1,:delete=>1,:subst=>2,:transpose=>0.1}' edist harrisburg harrsibugr
bin/fuzzy.rb -b '{:initial=>0,:match=>0,:insert=>1,:delete=>1,:subst=>2,:transpose=>0.1}' brew harrisburg harrsibugr

bin/fuzzy.rb -f data/lnames.txt -t 0.80 find edist burton
bin/fuzzy.rb -f data/lnames.txt -t 0.80 find soundex burton
bin/fuzzy.rb -f data/lnames.txt -t 0.80 find nysiis burton
bin/fuzzy.rb -f data/lnames.txt -t 0.80 find metaphone burton