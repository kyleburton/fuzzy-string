(require-extension srfi-13)           
(import foreign)
(import foreigners)
(use easyffi)

;; isn't there some way to get it to parse most of this out of the C header file?
(foreign-declare #<<EOF
#include "brew.h"
EOF
)

(foreign-parse "extern void                      brew_distance        (BrewConfig*,BrewEditDistanceResults*);")
(foreign-parse "extern void                      brewResults_destroy  (BrewEditDistanceResults*);")
(foreign-parse "extern BrewConfig*               brewConfig_new       (float,float,float,float,int);")
(foreign-parse "extern BrewEditDistanceResults*  brewResults_new      (const char* left, const char* right);")
(foreign-parse "extern void                      pathList_prettyPrint (PathList*pl,const char* left, const char* right);")
(foreign-parse "extern const char*               editTypeToString     (int);")
(foreign-parse "extern void                      brewConfig_destroy   (BrewConfig*);")
(foreign-parse "extern BrewMove*                 brew_matrixElt       (BrewEditDistanceResults*,int,int);")

(define-foreign-record-type [brew-edit-distance-results BrewEditDistanceResults]
  ;; (rename: (compose string-downcase (cut string-translate <> "_" "-")))
  (double          distance    brew-edit-distance-results-distance)
  (c-pointer       editPath    brew-edit-distance-results-editpath)
  (c-pointer       matrix      brew-edit-distance-results-matrix)
  (int             matrixXSize brew-edit-distance-results-matrix-x-size)
  (int             matrixYSize brew-edit-distance-results-matrix-y-size)
  (c-string        left        brew-edit-distance-results-left)
  (c-string        right       brew-edit-distance-results-right))

(define-foreign-record-type (brew-path-list PathList)
  ;; (rename: (compose string-downcase (cut string-translate <> "_" "-")))
  (int       editType   brew-path-list-edittype)
  (c-pointer prev       brew-path-list-prev)
  (c-pointer next       brew-path-list-next)
  (char      leftChar   brew-path-list-leftchar)
  (char      rightChar  brew-path-list-rightchar))

(define-foreign-record-type (brew-move BrewMove)
  ;; (rename: (compose string-downcase (cut string-translate <> "_" "-")))
  (double     bestCost  brew-move-bestcost)
  (int        editType  brew-move-edittype)
  (c-pointer  traceBack brew-move-traceback)
  (c-string   leftChar  brew-move-leftchar)
  (c-string   rightChar brew-move-rightchar))

(define *edit-type-table*
  '( ("*" "INITIAL")
     ("M" "MATCH")
     ("I" "INS")
     ("S" "SUBST")
     ("D" "DEL")))

(define *edit-type-long->short*
  (map (lambda (pair) (list (cadr pair) (car pair))) *edit-type-table*))

(define *edit-type-table-int*
  '( (0 "*")
     (1 "D")
     (2 "I")
     (3 "M")
     (4 "S")))

(define (char->editType ch)
  (cadr (assoc ch *edit-type-table*)))

(define (int->editType num)
  (cadr (assoc num *edit-type-table-int*)))

(define (edit-type->short type)
  (cadr (assoc type *edit-type-long->short*)))

; From the (brew-results BrewEditDistanceResults), pulls the paths list and turns it into a string list
;
;   #;25> (set! results (brewResults_new "foo" "foobar"))
;   #;26> (brew_distance *brew-config* results)
;   #;27> (convert-path-list results)
;   ("INITIAL" "MATCH" "MATCH" "MATCH" "INS" "INS" "INS")
;

(define (brew-pathlist-node->tuple pathlist)
  (list
   (brew-path-list-edittype pathlist)
   (editTypeToString (brew-path-list-edittype pathlist))
   (edit-type->short (editTypeToString (brew-path-list-edittype pathlist)))
   (brew-path-list-leftchar pathlist)
   (brew-path-list-rightchar pathlist)))

(define (null-pointer? thing)
  (not thing))

(define (convert-path-list brew-results)
  (let ((result '()))
    (cond ((null-pointer? brew-results)
           #f)
          (else
           (let loop ((path-list (brew-edit-distance-results-editpath brew-results)))
             (cond ((or (not path-list) 
                        (null-pointer? path-list))
                    #f)
                   (else
                    (set! result (cons (brew-pathlist-node->tuple path-list) result))
                    (loop (brew-path-list-next path-list)))))))
    (reverse (cdr result))))

(define (prevous...convert-path-list brew-results)
  (let ((result '()))
    (cond ((null-pointer? brew-results)
           #f)
          (else
           (let loop ((path-list (brew-edit-distance-results-editpath brew-results)))
             (cond ((or (not path-list) 
                        (null-pointer? path-list))
                    #f)
                   (else
                    (set! result (cons (brew-path-list-edittype path-list) result))
                    (loop (brew-path-list-next path-list)))))))
    (set! result (map editTypeToString result))
    (reverse (cdr result))))

(define (convert-path-list-short brew-results)
  (convert-path-list brew-results))

(define (brew-dist->path cfg left right)
  (let ((brew-dist-results (brewResults_new left right))
        (results '()))
    (brew_distance cfg brew-dist-results)
    (set! results (convert-path-list brew-dist-results))
    (brewResults_destroy brew-dist-results)
    results))
  


;; nb: if path doens't include at least one comma, you'll get the
;; following type fo error: "Error: (cadr) bad argument type: #f"
(define (make-pathlist path)
  (map char->editType (string-split path ",")))

