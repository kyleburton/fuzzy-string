bash chicken-run.sh src/chicken/*.scm -e "(printf \"~a\n\" (string->metaphone \"$1\"))"
