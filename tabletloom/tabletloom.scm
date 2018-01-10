(load "tablet2.scm")


(define (load-threads name)
  (with-state
   (translate (vector -1000 0 0))
   (list (load-obj (string-append "models/" name "-a.obj"))
	 (load-obj (string-append "models/" name "-b.obj"))
	 (load-obj (string-append "models/" name "-c.obj"))
	 (load-obj (string-append "models/" name "-d.obj")))))

(define weft-obj (with-state (translate (vector -1000 0 0)) 
			     (load-obj "models/weft-thick.obj")))

(define objs 
  (list 
   (list "ll" (load-threads "ll"))
   (list "rr" (load-threads "rr"))
   (list "ls" (load-threads "ls"))
   (list "rs" (load-threads "rs"))
   (list "sl" (load-threads "sl"))
   (list "sr" (load-threads "sr"))))

(define (reverse-n p) 
  (with-primitive 
   p
   (pdata-map! 
    (lambda (n) 
      (vector (- (vx n)) (- (vy n)) (- (vz n))))
    "n")
   (pdata-map! 
    (lambda (n) 
      (vector (- 1 (vx n)) (vy n) (vz n)))
    "t")))

(define (reverse-normals n)
  (reverse-n (list-ref (cadr (list-ref objs n)) 0))
  (reverse-n (list-ref (cadr (list-ref objs n)) 1))
  (reverse-n (list-ref (cadr (list-ref objs n)) 2))
  (reverse-n (list-ref (cadr (list-ref objs n)) 3)))

(define (reverse-n2 p) 
  (with-primitive 
   p
   (pdata-map! 
    (lambda (n) 
      (vector (+ (vx n)) (- (vy n)) (- (vz n))))
    "n")
   (pdata-map! 
    (lambda (n) 
      (vector (- 1 (vx n)) (vy n) (vz n)))
    "t")))

(define (reverse-normals2 n)
  (reverse-n2 (list-ref (cadr (list-ref objs n)) 0))
  (reverse-n2 (list-ref (cadr (list-ref objs n)) 1))
  (reverse-n2 (list-ref (cadr (list-ref objs n)) 2))
  (reverse-n2 (list-ref (cadr (list-ref objs n)) 3)))

(reverse-normals2 2)
(reverse-normals2 3)
(reverse-normals 4)

(define (thread->colour thread)
  (cond 
   ((eq? thread 'x) (colour (vector 0.6 0.3 0.1)))
   ((eq? thread 'y) (colour (vector 1 1 1)))
   ((eq? thread 'z) (colour (vector 1 0 1)))
   ((eq? thread 'a) (colour (vector 1 1 0)))))

(define (build-coloured element-name threads)
  (with-state
   (texture (load-texture "textures/thread2.png"))
   (let ((obj (cadr (assoc element-name objs))))
     (thread->colour (list-ref threads 0))
     (build-instance (list-ref obj 0))
     (thread->colour (list-ref threads 1))
     (build-instance (list-ref obj 1))
     (thread->colour (list-ref threads 2))
     (build-instance (list-ref obj 2))
     (thread->colour (list-ref threads 3))
     (build-instance (list-ref obj 3)))))

(define (build-threads element threads)
  (cond
   ((eq? element 'll) (build-coloured "ll" threads))
   ((eq? element 'rr) (build-coloured "rr" threads))
   ((eq? element 'ls) (build-coloured "ls" threads))
   ((eq? element 'rs) (build-coloured "rs" threads))
   ((eq? element 'sl) (build-coloured "sl" threads))
   ((eq? element 'sr) (build-coloured "sr" threads))
   (else (colour (vector 0 0 1)) (build-cube))))

(define (weave-render desc)
  (let ((structure (car desc))
	(threads (cadr desc)))
    (with-state
     (for-each
      (lambda (weft threads)
	(translate (vector 2 0 0))
	(with-state
	 (for-each 
	  (lambda (element threads)
	    (translate (vector 0 0 2))
	    (texture (load-texture "textures/thread2.png"))
	    (build-instance weft-obj)
	    (build-threads element threads))
	  weft threads)))
      structure threads))))

(define (weave-render-part desc)
  (let ((structure (car desc))
	(threads (cadr desc)))
    (let ((weft (car structure))
	  (threads (car threads)))
      (translate (vector 2 0 0))
      (with-state
       (for-each 
	(lambda (element threads)
	  (translate (vector 0 0 2))
	  (texture (load-texture "textures/thread2.png"))
	  (build-instance weft-obj)
	  (build-threads element threads))
	weft threads)))))

(define root (build-locator))

(define (rotate-list l)
  (append (cdr l) (list (car l))))

;;(define instructions (list 'cw 'cw 'cw 'cw 'cw 'cw 'cw 'cw 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw))
(define instructions (list 'cw 'cw 'cw 'cw 'ccw 'ccw 'ccw 'ccw 'cw 'cw 'cw 'cw 'ccw 'ccw 'ccw 'ccw))
;(define instructions (list 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw 'ccw 'cw 'cw 'cw 'cw 'cw 'cw 'cw 'cw))
;(define instructions (list 'cw 'cw 'ccw 'ccw 'cw 'cw 'ccw 'ccw 'cw 'cw 'ccw 'ccw 'cw 'cw 'ccw 'ccw))
;;(define instructions (list 'cw 'ccw 'cw 'ccw 'cw 'ccw 'cw 'ccw 'cw 'ccw 'cw 'ccw 'cw 'ccw 'cw 'ccw))

(define thread 
  '(
; 1
;    (x x y y) 
;    (x x y y) 
;    (x x y y) 
;    (x x y y) 
;    (x x y y) 
;    (x x y y) 
;    (x x y y) 
;    (x x y y) 

; 2
;    (x x y y) 
;    (y x x y)  
;    (y y x x) 
;    (x y y x) 
;    (x x y y) 	
;    (y x x y) 
;    (y y x x) 
;    (x y y x) 

; 3
;    (y x x y) 
;    (y x x y) 
;    (y x x y) 
;    (y x x y) 
;    (y x x y) 
;    (y x x y) 
;    (y x x y) 
;    (y x x y) 

(z z a a)
(y y x x)
(x y y x)
(x x y y)
(y x x y)

(x y y x)
(x x y y)
(y x x y)
(y y x x)

(z z a a)

    ))


(define temp '())

(define frame 51)
(define frames-per-generate 50)
(define pos 0)
(define roots '())

(define (render-me)
  ;(with-primitive 
  ; root 
   ;;(translate (vector (* -0.98 (/ 1 frames-per-generate)) 0 0)))

  (when (> frame frames-per-generate)
	(set! pos (+ pos 1))
	;;(set! frame 0)
	
	;(set! instructions (rotate-list instructions))
	;(msg instructions)
	(destroy root)
	(set! root (build-locator))

	
	(with-state
	 (parent root)
	 (rotate (vector 20 45 180))
	 (translate (vector -8 0 0))
	 (scale (vector 0.5 0.5 0.5))
	 
	 (set! temp 
	       (weave
		instructions
		thread
		'(right right right right right
		  left left left left left
		  )))
	 (msg (cdr temp))

	 (weave-render temp)
	 ;;(set! thread (car (cadr temp)))
	 ;(msg thread)
	 ))
  
  ;(set! frame (+ frame 1))
  )

(clear-colour (vector 1 1 1))

(define camera (build-locator))
(lock-camera camera)
(with-primitive 
 camera
 (rotate (vector 0 0 0))
 (translate (vector 0 0 15)))

;;(render-me)

(every-frame (render-me))

;;(every-frame (with-primitive root (rotate (vector 0 0.3 0))))




