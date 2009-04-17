(load-relative "fuzzy-lib.scm")
(load-relative "soundex.scm")
(load-relative "metaphone-match.scm")
(load-relative "nysiis.scm")
(load-relative "edit-distance.scm")
(load-relative "ascii-frequency.scm")

(define *encodings* (list soundex string->metaphone nysiis))
;(define *encodings* (list soundex))

;; for each of the algorithms, find the matches



(define *default-lnames-file* 
  (expand-tilde-file "~/personal/presentations/fuzzy-string/data/lnames.txt"))

(define (find-phonetic-lname-matches encoder string #!optional (lname-file *default-lnames-file*))
  (let ((target (encoder string))
        (results (list)))
    (printf "looking for ~a / ~a with ~a\n~!" string target encoder)
    (for-each-line
     *default-lnames-file*
     (lambda (line)
       (when (string=? target (encoder line))
             (printf "  ~a: ~a\n~!" encoder line)
             (set! results (cons line results)))))))

(define (find-lname-matches name matcher #!optional (lname-file *default-lnames-file*))
  (let ((results (list)))
    (printf "~a in ~a\n" name lname-file)
    (for-each-line
     *default-lnames-file*
     (lambda (line)
       (when (matcher line)
             (printf "  ~a:~a\n~!" name line)
             (set! results (cons line results)))))
    (printf "~a, found ~a results\n" name (length results))
    results))


(define (find-matches string #!optional (lname-file *default-lnames-file*))
  (aprog1
   (soundex string)
   (find-lname-matches 
    "Soundex" 
    (lambda (candidate) (string=? it (soundex candidate)))))
  (aprog1
   (string->metaphone string)
   (find-lname-matches
    "Metaphone" 
    (lambda (candidate) (string=? it (string->metaphone candidate)))))
  (aprog1
   (nysiis string)
   (find-lname-matches
    "Nysiis"
    (lambda (candidate) (string=? it (nysiis candidate)))))
  (find-lname-matches
   "Ascii Frequency/75%" 
   (lambda (candidate)
     (>= (ascii-frequency candidate string)
         0.75)))
  (find-lname-matches
   "Edit Distance/75%"
   (make-edit-distance-matcher string 0.75)))

(define (...find-matches string #!optional (lname-file *default-lnames-file*))
  (aprog1
   (soundex string)
   (find-lname-matches 
    "Soundex" 
    (lambda (candidate) (string=? it (soundex candidate)))))
  '(aprog1
   (string->metaphone string)
   (find-lname-matches
    "Metaphone" 
    (lambda (candidate) (string=? it (string->metaphone candidate)))))
  '(aprog1
   (nysiis string)
   (find-lname-matches
    "Nysiis"
    (lambda (candidate) (string=? it (nysiis candidate)))))
  '(find-lname-matches
   "Ascii Frequency/75%" 
   (lambda (candidate)
     (>= (ascii-frequency candidate string)
         0.75)))
  '(find-lname-matches
   "Edit Distance/75%"
   (make-edit-distance-matcher string 0.75)))

