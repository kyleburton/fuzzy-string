;(load-relative "fuzzy-lib.scm")

(define *unused-regex* #/[^AaEeHhIiOoUuWwYyBbFfPpVvCcGgJjKkQqSsXxZzDdTtLlMmNnRr]/)

(define (sndx-remove-unused string)
  (string-substitute *unused-regex* "" (string-upcase string) #t))

(define *subst-map*
  (list
   (cons #/[AaEeHhIiOoUuWwYy]/ "0")
   (cons #/[BbFfPpVv]/         "1")
   (cons #/[CcGgJjKkQqSsXxZz]/ "2")
   (cons #/[DdTt]/             "3")
   (cons #/[Ll]/               "4")
   (cons #/[MmNn]/             "5")
   (cons #/[Rr]/               "6")))

(define (sndx-chars->code string)
  (string-substitute*
   (sndx-remove-unused string)
   *subst-map*))

(define (soundex string)
  (let* ((clean (sndx-remove-unused string))
         (first-char (substring clean 0 1))
         (code (remove-duplicate-chars
                (sndx-chars->code clean))))
    (set! code (substring code 1))
    (set! code (string-substitute "0" "" code #t))
    (substring (string-append first-char code "000")
               0 4)))

(define (test file #!optional (verbose #f))
  (let ((pass 0)
        (fail 0))
    (for-each
     (lambda (pair)
       (if (and verbose (= 0 (modulo pass 1000)))
           (printf "~a passed, ~a failed\n" pass fail))
       (let* ((in-code (car pair))
              (string (cadr pair))
              (code (soundex string)))
         (if (not (string=? code in-code))
             (begin 
               (printf "FAIL: ~a,~a but got ~a\n"
                       string in-code code)
               (incf fail))
             (incf pass))))
     (map tab-line->fields (file->lines file)))
    (list pass fail)))

(define (test3 file #!optional (verbose #f))
  (let ((pass 0)
        (fail 0))
    (for-each
     (lambda (line)
       (if (and verbose (= 0 (modulo pass 1000)))
           (printf "~a passed, ~a failed\n" pass fail))
       (match 
        (tab-line->fields line)
        ((in-code string)
         (let ((code (soundex string)))
           (if (not (string=? code in-code))
               (begin 
                 (printf "FAIL: ~a,~a but got ~a\n"
                         string in-code code)
                 (set! fail (+ 1 fail)))
               (set! pass (+ 1 pass)))))))
     (file->lines file))
    (list pass fail)))

(define (test2 file #!optional (verbose #f))
  (let ((pass 0)
        (fail 0))
    (for-each-line 
     file
     (lambda (line)
       (if (and verbose (= 0 (modulo pass 1000)))
           (printf "~a passed, ~a failed\n" pass fail))
       (match 
        (tab-line->fields line)
        ((in-code string)
         (let ((code (soundex string)))
           (if (not (string=? code in-code))
               (begin 
                 (printf "FAIL: ~a,~a but got ~a\n"
                         string in-code code)
                 (set! fail (+ 1 fail)))
               (set! pass (+ 1 pass))))))))
    (list pass fail)))

'(time (match 
       (test (expand-tilde-file "~/personal/presentations/fuzzy-string/data/lname-perl-soundex.tab") #t)
       ((pass fail)
        (printf "~a tests passed\n" pass)
        (printf "~a tests failed\n" fail))))

