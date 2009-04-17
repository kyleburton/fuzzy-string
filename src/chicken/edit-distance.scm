;(load-relative "fuzzy-lib.scm")

(use levenshtein)

(define (edit-distance-sim left right)
  (- 1.0
     (/ (levenshtein-distance/generic-sequence left right)
        (/
         (+ (string-length left) (string-length right))
         2.0))))

(define (make-edit-distance-matcher target threshold)
  (lambda (str)
    (>= (edit-distance-sim target str)
        threshold)))
