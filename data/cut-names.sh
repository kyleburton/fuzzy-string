cut -c1-15 dist.all.last | perl -ne 's/\s+//; print "$_\n"' > lnames.txt

cut -c1-15 dist.female.first | perl -ne 's/\s+//; print "$_\n"' > female-first.txt

cut -c1-15 dist.male.first | perl -ne 's/\s+//; print "$_\n"' > male-first.txt


cat female-first.txt male-first.txt | sort -u > fnames.txt


