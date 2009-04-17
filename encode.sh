bash chicken-run.sh -q src/chicken/*.scm -e '(encode-file "data/lnames.txt" string->metaphone)' | less
