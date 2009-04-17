;(load-relative "fuzzy-lib.scm")


(define (get-frequency-hash string)
  (let ((ht (make-hash-table))
        (target (string-upcase string)))
    (let loop ((idx (- (string-length string) 1)))
      (cond
       ((< idx 0)
        ht)
       ((hash-table-exists? ht (string-ref string idx))
        (hash-table-set! ht (string-ref string idx)
                         (+ 1 (hash-table-ref ht (string-ref string idx))))
        (loop (- idx 1)))
       (else
        (hash-table-set! ht (string-ref string idx) 1)
        (loop (- idx 1)))))))

;; (hash-table-map ht (lambda (key val) (list key val)))
;; (hash-table->alist (get-frequency-hash "KYLE BURTON"))

(define (ascii-in-common left right)
  (let ((left-ht (get-frequency-hash left))
        (right-ht (get-frequency-hash right))
        (total 0))
    (hash-table-map 
     left-ht
     (lambda (key val)
             (if (hash-table-exists? right-ht key)
                 (incf total (min (hash-table-ref left-ht key)
                                  (hash-table-ref left-ht key))))))
    total))

(define (ascii-frequency left right)
  (/ (ascii-in-common left right)
     (/ (+ (string-length left)
           (string-length right))
        2)))


