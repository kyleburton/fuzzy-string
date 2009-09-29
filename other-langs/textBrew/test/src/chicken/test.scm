(require 'brew)
(require 'utils)
(require 'extras)
(require 'srfi-13) ;; string utilities

(define *verbose* #f)
(define *print-matrix* 0) ; 0 => off; 1 => on

(define *match-cost*       0.0)
(define *insert-cost*      0.1)
(define *delete-cost*     15.0)
(define *substitute-cost*  1.0)
(define *brew-config* (brewConfig_new *match-cost* *insert-cost* *delete-cost* *substitute-cost* *print-matrix*))

(define *score-test-case-file* "data/test-cases.tab")

;; split a tab delimited string
(define (tab-line->fields line)
  (string-split line "\t"))

;; split a multi-line string on newline characters
(define (buff->lines buff)
  (string-split buff "\n"))

;; pull the test cases from *score-test-case-file* and turn them into
;; a list of tuples
(define (get-test-cases)
  (cdr (map tab-line->fields (buff->lines (read-all *score-test-case-file*)))))

;; load the test cases
(define *test-cases* (get-test-cases))

;; convert a BrewMove C struct into a list of best-cost, move-type
;; (int) and move-type (descriptive character, *,M,I,D,S)
(define (brew-move->tuple move)
  (list
   (brew-move-bestcost move)
   (brew-move-edittype move)
   (int->editType (brew-move-edittype move))
   (brew-move-leftchar move)
   (brew-move-rightchar move)))

(define (matrix-row->list brew-results colnum)
  (let ((row '())
        (numRows (brew-edit-distance-results-matrixysize brew-results)))
    (let loop ((rownum 0))
      (cond ((<= rownum numRows)
             (set! row (cons (brew-move->tuple (brew_matrixElt brew-results colnum rownum)) row))
             (loop (+ 1 rownum)))
            (else ; stop
             #f)))
    (reverse row)))

(define (matrix-dump brew-results)
  (let ((matrix (brew-edit-distance-results-matrix brew-results))
        (numCols (brew-edit-distance-results-matrixxsize brew-results))
        (result '()))
    (do ((colnum 0 (+ colnum 1)))
        ((> colnum numCols))
      (set! result (cons (matrix-row->list brew-results colnum) result)))
    (reverse result)))

(define (my-test left right #!optional (brew-config *brew-config*))
  (let ((brew-results (brewResults_new left right)))
    (matrix-dump brew-results)
    (brew_distance brew-config brew-results)
    (printf "EDITS: ~a\n" (convert-path-list-short brew-results))
    (matrix-dump brew-results)))

(define (string-truncate-len str len)
  (if (< (string-length str) len)
      str
      (substring str 0 len)))

(define (matrix->tab-block mlist)
  (string-join 
   (map 
    (lambda (row) 
      (string-join 
       (map 
        (lambda (cell) 
          (string-join (map (lambda (s) (string-truncate-len s 5)) (map ->string cell)) ",")) 
        row)
       "\t")) 
    mlist)
   "\n"))

(define (close-enough actual expected epsilon)
  (< (abs (- actual expected)) epsilon))

;; for-each-line, and for-each-argv-line

(define *tests-run* 0)
(define *tests-passed* 0)
(define *tests-failed* 0)
(define (test-passed)
  (set! *tests-run* (+ 1 *tests-run*))
  (set! *tests-passed* (+ 1 *tests-passed*)))

(define (test-failed)
  (set! *tests-run* (+ 1 *tests-run*))
  (set! *tests-failed* (+ 1 *tests-failed*)))

(define (test-summary)
  (printf "Tests Run: ~a\n" *tests-run*)
  (printf "Tests Passed: ~a\n" *tests-passed*)
  (printf "Tests Failed: ~a\n" *tests-failed*)
  (printf "~a\n" (if (= 0 *tests-failed*) "SUCCESS" "FAILURE")))

(define (execute-tests)
  (and *verbose* (printf "~a\n" (string-join '("LEFT" "RIGHT" "ACTUAL_DIST" "EXPECTED_DIST" "DIST_SUCCESS" "ACTUAL_PATH" "EXPECTED_PATH" "PATH_SUCCESS") "\t")))
  (for-each
   (lambda (case)
     (let* ((left (car case))
            (right (cadr case))
            (expected-score (string->number (caddr case)))
            (brew-results (brewResults_new left right))
            (actual-path #f)
            (passed #f)
            (expected-path (cadddr case)))
       (brew_distance *brew-config* brew-results)
       ;; changed when I added left/right chars to the path...
       ;; (set! actual-path (string-join (convert-path-list-short brew-results) ","))
       (set! actual-path (string-join (map ->string (convert-path-list-short brew-results)) ","))
       (set! passed (close-enough expected-score (brew-edit-distance-results-distance brew-results) 0.000001))
       (if passed
           (test-passed)
           (test-failed))
       (if (or *verbose* (not passed))
           (printf "~a\t~a\t~a\t~a\t~a\t~a\t~a\t~a\n" 
                   left
                   right
                   (brew-edit-distance-results-distance brew-results)
                   expected-score
                   (if passed "PASS" "FAIL")
                   expected-path
                   actual-path
                   (if (equal? expected-path actual-path) "PASS" "FAIL")))
       (brewResults_destroy brew-results)))
   *test-cases*)
  (test-summary))

; does chicken support atexit?
;(brewConfig_destroy *brew-config*)
;(exit)


(define (verbose-test #!optional (left "BRYN MAWR PIZZA II")
                                 (right "BEIJING CHINESE RESTAURANT")
                                 (match-cost 0.0)
                                 (ins-cost   1.0)
                                 (del-cost   1.0)
                                 (sub-cost   1.0))
  (let* ((brew-config (brewConfig_new match-cost ins-cost del-cost sub-cost *print-matrix*))
         (matrix (my-test left right brew-config))
         (inverted-matrix '()))
    (set! inverted-matrix (map reverse (reverse matrix)))
    (printf "Matrix (~a) vs (~a):\n" left right)
    (printf "~a\n" (matrix->tab-block matrix))
    '(printf "Inverted Matrix:\n")
    '(printf "~a\n" (matrix->tab-block inverted-matrix))))

