;; utils

(define (list-wrap-ref l n)
  (list-ref l (modulo n (length l))))

;; safely return last, current and next from a list
(define (list-hist-ref l n)
  (cond
    ((zero? n) (list 'nil (list-ref l 0) (list-ref l 1)))
    ((eqv? n (- (length l) 1)) (list (list-ref l (- n 1)) (list-ref l n) 'nil))
    (else (list (list-ref l (- n 1)) (list-ref l n) (list-ref l (+ n 1)))))) 

;; structure

(define (flip-direction dir) (if (eq? dir 'cw) 'ccw 'cw))

;; threads define colours/pattern contained within tablets

(define (rotate-thread threads dir)
  (if (eq? dir 'cw)
      (list
       (list-ref threads 1) (list-ref threads 2) 
       (list-ref threads 3) (list-ref threads 0))
      (list
       (list-ref threads 3) (list-ref threads 0) 
       (list-ref threads 1) (list-ref threads 2))))

(define (flip-threads threads)
  (list
   (list-ref threads 1) (list-ref threads 0) 
   (list-ref threads 3) (list-ref threads 2)))

(define (rotate-threads tablets dir orientation)
  (map
   (lambda (t flip) 
     (rotate-thread t (if (eq? flip 'left) dir (flip-direction dir)))) 
   tablets orientation))

(define (weave-unit direction threads orientation)
  (let ((dir (if (eq? orientation 'left) direction (flip-direction direction))))
    (if (eq? dir 'cw) 'll 'rr)))

(define (weave-tablet direction threads orientation n)
  (cond
   ((null? threads) '())
   (else
    (cons (weave-unit direction (car threads) (list-wrap-ref orientation n))
          (weave-tablet direction (cdr threads) orientation (+ n 1))))))

(define (instructions->structure instructions threads orientation)
  (cond
   ((null? instructions) '())
   (else
    (let ((new-threads (rotate-threads threads (car instructions) orientation)))
      (cons (weave-tablet (car instructions) threads orientation 0)
            (instructions->structure (cdr instructions) new-threads orientation))))))

(define (instructions->thread instructions threads orientation)
  (cond
   ((null? instructions) '())
   (else
    (let ((new-threads (rotate-threads threads (car instructions) orientation)))
      (cons new-threads
	    (instructions->thread (cdr instructions) new-threads orientation))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; broken version

(define (weft->dir weft)
  (cond
    ((or (eq? weft 'll) (eq? weft 'sl)) 'left)
    ((or (eq? weft 'rr) (eq? weft 'sr)) 'right)
    (else 'straight)))

(define (weft->structure weft last)
  (cond
   ((eq? last 'll) (if (eq? weft 'll) 'll 'ls))
   ((eq? last 'rr) (if (eq? weft 'rr) 'rr 'rs))
   ((eq? last 'ls) (if (eq? weft 'll) 'sl 'sr))
   ((eq? last 'rs) (if (eq? weft 'rr) 'sr 'sl))
   ((eq? last 'sl) (if (eq? weft 'll) 'll 'rs))
   ((eq? last 'sr) (if (eq? weft 'rr) 'rr 'ls))
   (else (display last)(newline))))

(define (weft-tension weft last)
  (map
   (lambda (weft last)
     (weft->structure weft last))
   weft last))

(define (weave-tension weave)
  (define (_ weave last)
    (cond
     ((null? weave) '())
     (else
      (let ((weft (weft-tension (car weave) last)))
	(cons weft (_ (cdr weave) weft))))))
  (_ weave (build-list (lambda (_) 'll) (length (car weave)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; working version

(define (reslice l)
  (cond
    ((null? (cdr (cdr l))) '())
    (else (cons (list (car l) (cadr l) (caddr l))
                (reslice (cdr l))))))

(define (transpose l)
  (foldl
   (lambda (l r)     
     (map
      (lambda (r e)
        (append r (list e)))
      r l))
   (build-list (lambda (_) '()) (length (car l)))
   l))

(define (retrans l)
  (transpose
   (map (lambda (l) (reslice l)) (transpose l))))


(define (struct-eq? a b)
  (and (eq? (list-ref a 0) (list-ref b 0))
       (eq? (list-ref a 1) (list-ref b 1))
       (eq? (list-ref a 2) (list-ref b 2))))

(define (weft->structure2 last hist)
  (cond
   ((struct-eq? hist '(ll ll ll)) 'll) ;; simple twist
   ((struct-eq? hist '(rr rr rr)) 'rr) ;; simple twist
   ((struct-eq? hist '(rr rr ll)) 'rs) ;; first turn -> straight
   ((struct-eq? hist '(ll ll rr)) 'ls) ;; first turn -> straight
   ;; special case for coming out of a float, 
   ;; ready to go straight to twist
   ((struct-eq? hist '(rr ll ll)) (if (eq? last 'sr) 'll 'sl)) 
   ((struct-eq? hist '(ll rr rr)) (if (eq? last 'sl) 'rr 'sr)) 
   ;; special case for a float, as the direction matters
   ((struct-eq? hist '(rr ll rr)) (if (eq? last 'sr) 'ls 'sl))
   ((struct-eq? hist '(ll rr ll)) (if (eq? last 'sl) 'rs 'sr))
   (else (display hist)(newline))))

(define (weft-tension2 last hist)
  (map
   (lambda (last hist)
     (weft->structure2 last hist))
   last hist))

(define (weave-tension2 weave start)
  (define (_ last hist)
    (cond
     ((null? hist) '())
     (else
      (let ((weft (weft-tension2 last (car hist))))
	(cons weft (_ weft (cdr hist)))))))
  
  (_ start (retrans weave)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (weave instructions threads orientation)
  (list
   (weave-tension2
    (instructions->structure instructions threads orientation)
    (map (lambda (o) (if (eq? o 'left) 'll 'rr)) orientation))
   (instructions->thread instructions threads orientation)))
    
  
