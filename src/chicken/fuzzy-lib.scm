(use regex-literals)
(use regex)
(use utils)
(use extras)
(use srfi-13) ;; string utils

(define *dupes-regex* #/(.)\1+/)

(define (remove-duplicate-chars str)
  (string-substitute *dupes-regex* "\\1" str #t))

(define (file.head file #!optional (nlines 5))
  (read-lines (open-input-file file)
              nlines))

(define (buff->lines buff)
  (string-split buff "\n"))

(define (file->lines file)
  (buff->lines (read-all file)))

(define-macro (incf place #!optional (nn 1))
  `(set! ,place (+ ,place ,nn)))

;; (macroexpand '(incf x))

(define (expand-tilde-file fname)
  (cond 
   ((string=? "~" fname)
    (getenv "HOME"))
   ((< (string-length fname) 2)
    fname)
   ((string=? "~/" (substring fname 0 2))
    (string-append (getenv "HOME")
                   (substring fname 1)))
   (else
    fname)))

(define (tab-line->fields line)
  (string-split line "\t"))

(define (lpad str nn #!optional (pfx " "))
  (cond ((< (string-length str)
            nn)
         (lpad (string-append pfx str)
               nn
               pfx))
        (else
         str)))

(define (for-each-line file unary-proc)
  (let ((handle (open-input-file file)))
    (let loop ((line (read-line handle)))
      (cond ((eof-object? line)
             #t)
            (else
             (unary-proc line)
             (loop (read-line handle)))))))


(define (encode-file file encoder #!optional (outfile "/dev/stdout"))
  (let ((output-port (open-output-file (expand-tilde-file outfile))))
    (for-each-line
     (expand-tilde-file file)
     (lambda (line)
       (let ((encoding (encoder line)))
         (fprintf output-port "~a\t~a\n" encoding line))))
    ;; ok, how do you close a port?
    ))

(define (safe-substring string start #!optional end)
  (if (not end)
      (set! end (string-length string)))
  (if (>= end (string-length string))
      (set! end (string-length string)))
  (cond
   ((> start (string-length string))
    "")
   ((> (string-length string) 0)
    (substring string start end))
   (else
    string)))

(define-macro (aprog1 thing . body)
  `(let ((it ,thing))
     ,@body
     it))
