bash chicken-run.sh src/chicken/*.scm \
  -e "(printf \"~a ~a\n\" (levenshtein-distance/generic-sequence \"$1\" \"$2\") (edit-distance-sim \"$1\" \"$2\"))"
