;(load-relative "fuzzy-lib.scm")

(define (nysiis string)
  (let ((first ""))
    (set! string (string-upcase string))
    
    (set! string (string-substitute "[^A-Za-z]" "" string #t))
    ;; chicken regex lib can't handle this?
    ;;   $string =~ s/[SZ]*$//g;
    ;;   (set! string (string-substitute "[SZ]*$" "" string #t))
    (set! string (string-substitute "[SZ]+$" "" string #t))
    (set! string (string-substitute "^MAC" "MC" string #t))
    (set! string (string-substitute "^PF" "F" string ))

    (set! string (string-substitute "IX$" "IC" string ))
    (set! string (string-substitute "EX$" "EC" string ))
    (set! string (string-substitute "(?:YE|EE|IE)$" "Y" string ))
    (set! string (string-substitute "(?:NT|ND)$" "N" string ))

    (set! string (string-substitute "(.)EV" "\\1EF" string #t))
    (set! first (safe-substring string 0 1))
    (set! string (string-substitute "[AEIOU]+" "A" string #t))
    ;;(printf "after vowel collapse: ~a\n" string)
    (set! string (string-substitute "AW" "A" string #t))
      
    (set! string (string-substitute "GHT" "GT" string #t))
    (set! string (string-substitute "DG" "G" string #t))
    (set! string (string-substitute "PH" "F" string #t))
    (set! string (string-substitute "(.)(?:AH|HA)" "\\1A" string #t))
    (set! string (string-substitute "KN" "N" string #t))
    (set! string (string-substitute "K" "C" string #t))
    (set! string (string-substitute "(.)M" "\\1N" string #t))
    (set! string (string-substitute "(.)Q" "\\1G" string #t))
    (set! string (string-substitute "(?:SCH|SH)$" "S" string ))
    (set! string (string-substitute "YW" "Y" string #t))
    
    (set! string (string-substitute "(.)Y(.)" "\\1A\\2" string #t))
    (set! string (string-substitute "WR" "R" string #t))
    
    (set! string (string-substitute "(.)Z" "\\1S" string #t))
    
    (set! string (string-substitute "AY$" "Y" string ))
    (set! string (string-substitute "A+$" "" string ))

    (set! string (string-substitute "(\\w)\\1+" "\\1" string #t))

    (if (string-match "^[AEIOU]" first)
        (set! string (string-append first (safe-substring string 1)))))
  string)


(define (test file #!optional (verbose #f))
  (let ((pass 0)
        (fail 0))
    (for-each
     (lambda (pair)
       (if (and verbose (= 0 (modulo pass 1000)))
           (printf "~a passed, ~a failed\n" pass fail))
       (let* ((in-code (car pair))
              (string (cadr pair))
              (code (nysiis string)))
         (if (not (string=? code in-code))
             (begin 
               (printf "FAIL: ~a,~a but got ~a\n"
                       string in-code code)
               (incf fail))
             (incf pass))))
     (map tab-line->fields (file->lines file)))
    (list pass fail)))

'(time (match 
       (test (expand-tilde-file "~/personal/presentations/fuzzy-string/data/lname-perl-nysiis.tab") #t)
       ((pass fail)
        (printf "~a tests passed\n" pass)
        (printf "~a tests failed\n" fail))))
