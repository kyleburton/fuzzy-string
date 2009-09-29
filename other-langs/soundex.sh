bash chicken-run.sh src/chicken/*.scm -e "(printf \"~a\n\" (soundex \"$1\"))"
