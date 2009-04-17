;(load-relative "fuzzy-lib.scm")

(use metaphone)
;(require 'metaphone)

(define (string->metaphone str)
  (metaphone-key-primary (make-metaphone-key str #:keyint? #f)))

(define (metaphone-str= s1 s2)
  (string=? (string->metaphone s1)
            (string->metaphone s2)))

;(metaphone-str= "Burton" "Barton")
;(metaphone-str= "Burton" "Bartin")


(define (metaphone-file file #!optional (outfile "/dev/stdout"))
  (encode-file file string->metaphone outfile))

