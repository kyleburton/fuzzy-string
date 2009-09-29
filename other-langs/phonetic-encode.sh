# time bash chicken-run.sh -q src/chicken/*.scm \
#   -e '(encode-file "data/lnames.txt" string->metaphone "data/metaphone-lnames.tab")'

time cut -f1 data/metaphone-lnames.tab | sort | uniq -c | sort -nr > data/metaphone-lname-counts.tab

# time bash chicken-run.sh -q src/chicken/*.scm \
#   -e '(encode-file "data/lnames.txt" nysiis "data/nysiis-lnames.tab")'

time cut -f1 data/nysiis-lnames.tab | sort | uniq -c | sort -nr > data/nysiis-lname-counts.tab

# time  bash chicken-run.sh -q src/chicken/*.scm \
#   -e '(encode-file "data/lnames.txt" soundex "data/soundex-lnames.tab")'

time cut -f1 data/soundex-lnames.tab | sort | uniq -c | sort -nr > data/soundex-lname-counts.tab

