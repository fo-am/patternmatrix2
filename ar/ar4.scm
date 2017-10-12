(require fluxus-018/fluxus-video)
(require fluxus-018/fluxus-artkp)

(clear)
(camera-clear-cache)
(camera-list-devices)

(define (choose l) (list-ref l (random (length l))))

;; check the device id's in the console and change the first parameter of
;; camera-init to the id
(define cam (camera-init 0 800 600))

;; init the ar system with the camera resolution and the camera parameter file
(ar-init (camera-width cam) (camera-height cam) "data/camera_para.dat")

;; enable automatic threshold calculation to adapt to different lighting conditions
(ar-auto-threshold #t)

(set-projection-transform (ar-get-projection-matrix))
(set-camera-transform (mident))

;; display the camera texture
(let ([p (build-image cam #(0 0) (get-screen-size))]
        [tcoords (camera-tcoords cam)])
    (with-primitive p
        (pdata-index-map!
            (lambda (i t)
                (list-ref tcoords (remainder i 4)))
            "t")))

(define base-transform (vector 3.4539895057678223 4.040801048278809 -8.470057487487793 0.0 9.328239440917969 -2.4656190872192383 2.6276755332946777 0.0 -1.026602029800415 -8.808669090270996 -4.620977878570557 0.0 63.60163497924805 -54.3501091003418 454.0171813964844 1.0))
;;(define base-transform (mident))

(define (arloop)
    ;; get next frame from camera
    (camera-update cam)
    (when (key-pressed " ") 
        ;; detect the markers in the image 
        (let ([marker-count (ar-detect (camera-imgptr cam))])
            ;; get the modelview matrix of each marker and draw
            ;; a cube on the marker
            (printf "detected markers: ~a~n" marker-count)
            (for ([i (in-range marker-count)])
         ;; scale it up to pattern width (80mm)
         ;; units are cm
         (let ([m (mmul (ar-get-modelview-matrix i) (mscale (vector 10 10 10)))]
               [id (ar-get-id i)]
               [cf (ar-get-confidence i)])
           (printf "index:~a id:~a cf:~a ~n" i id cf)
           (when (eq? id 0)
             (set! base-transform m)
             (with-state
              (hint-none)
              (hint-wire)
              (backfacecull 0)
              (line-width 5)
              (concat m)
              (scale (vector 8 8 8))
              ;; move the cube center up by half to match the marker
              (translate #(0 0 .5))
              (draw-cube))))))))

(clear-colour (vector 0.2 0.2 0.2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define font "fonts/Inconsolata.otf")

(define (build-text-prim text)
  (let* ((p (build-extruded-type font text 1)))
    (with-primitive 
     p
    (backfacecull 0)
    (colour (vector 1 0.2 0.5))
    (identity) ;; clear state transform
    (rotate (vector 0 0 0))
    (translate (vector -1.5 0 1))
    p)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (build-circle-prim w)
  (let ((p (with-state
        (hint-unlit)
        (texture (load-texture "textures/rainbow.png"))
    (colour (vector 1 1 0))
        (build-ribbon 100))))
    (with-primitive 
     p
     (pdata-add "vel" "v")
     (pdata-add "pref" "v")
     (hint-nozwrite)
     ;;(blend-mode 'src-alpha 'one)
     (pdata-map! (lambda (c) (vector 1 (* (rndf) 0.2) (* (rndf) 0.4))) "c")
     (pdata-map! (lambda (c) (vmul (vector 0.5 0.5 0.5) (rndf))) "s")
     (pdata-map! (lambda (c) w) "w")
     (pdata-index-map! (lambda (i p) 
               (let ((a (* 2 (/ i (- (pdata-size) 1)) 3.141)))
                 (vmul (vector (sin a) (cos a) 0) 2)))
               "p")
     (pdata-index-map! (lambda (i p) 
               (let ((a (* 2 (/ i (- (pdata-size) 1)) 3.141)))
                 (vmul (vector (sin a) (cos a) 0) 2)))
               "vel")
     (pdata-copy "p" "pref"))
    p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-token root gumpf text t last-text flash-t)
  (list root gumpf text t last-text flash-t))

(define (token-root t) (list-ref t 0))
(define (token-gumpf t) (list-ref t 1))
(define (token-text t) (list-ref t 2))
(define (token-t t) (list-ref t 3))
(define (token-last-text t) (list-ref t 4))
(define (token-flash-t t) (list-ref t 5))

(define (build-token)
  (let ((root (build-locator)))
    (let ((layers
       (append
        ;(list (with-state
;           (hint-nozwrite)
;           (texture (load-texture "textures/font.png"))
;           (build-text "testing...")))
        (build-list
         0
         (lambda (i)
           (with-state
        (identity)
        (hint-nozwrite)
        (texture (load-texture (choose (list "textures/square.png"
					     "textures/triangle.png"
					     "textures/circle.png"
					     "textures/rect.png"))))
        (parent root)
        (translate (vector 0 0 1))
        (scale (vector 5 5 5))
        (build-plane)))))))
      (let ((gumpf (cons (build-circle-prim 1) layers))
        (text
         (with-state
          (parent root)
          (build-text-prim (string (choose (string->list "ABCDabcd+-<>?")))))))
    (make-token root gumpf text 0 "?" 0)))))
  
(define (token-update-text token new-text)
  (cond
   ((string=? (token-last-text token) new-text)
    token)
   (else    
    (let ((text
       (with-state
        (parent (token-root token))
        (build-text-prim new-text))))
      (emit-particles (vtransform (vector 0 0 0) 
                  (with-primitive 
                   (token-root token)
                   (get-transform))))
      (destroy (token-text token))
      (make-token 
       (token-root token) 
       (token-gumpf token) 
       text 
       0.5
       new-text
       (token-flash-t token))))))

(define (sq n) (* n n))

(define (token-update token)
  (with-primitive
    (car (token-gumpf token))
    (when (> (token-flash-t token) 0)
	  (let ((c (vlerp (vector 1 1 0) (vector 1 0.2 0.4) (* 2 (token-flash-t token)))))
	    (colour c))
	  ;;(pdata-map! (lambda (p pref v) (vadd pref (vmul v (token-flash-t token)))) "p" "pref" "vel"))
	  ;;(pdata-index-map! (lambda (i w) (+ 0.5 (* 0.4 (sin (* 0.5 (+ i (* (token-flash-t token) 40))))))) "w"))
	  (pdata-index-map! (lambda (i w) (+ 1 (* (token-flash-t token) (sin (* 0.25 i))))) "w"))
    (if (> (token-t token) 0)
	(pdata-map! (lambda (p pref) (vadd pref (vmul (srndvec) (* 10 (token-t token))))) "p" "pref")
	(pdata-copy "pref" "p"))
    )
  (when (> (token-t token) 0)
    (with-primitive
     (token-text token)
     (identity)     
     (translate (vector 1 0 1))
     (scale (+ 1 (sq (* 5 (token-t token)))))
     (translate (vector -1 0 0))
     (translate (vector -1.5 0 0))
;;     (rotate (vector 90 90 0))
     ))
  (make-token 
   (token-root token) 
   (token-gumpf token) 
   (token-text token) 
   (- (token-t token) (delta))
   (token-last-text token)
   (- (token-flash-t token) (delta))))

(define (token-flash token)
  (make-token 
   (token-root token) 
   (token-gumpf token) 
   (token-text token) 
   (- (token-t token) (delta))
   (token-last-text token)
   0.5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (build-row n)
  (cond 
   ((zero? n) '())
   (else 
    (with-state
     (translate (vector 8.5 0 0))
     (cons (build-token) (build-row (- n 1)))))))


(define (build-grid x y)
  (cond 
   ((zero? y) '())
   (else
    (with-state
     (translate (vector 0 8.5 0))
     (append (reverse (build-row x)) (build-grid x (- y 1)))))))

(define (update-grid grid str)
  (map
   (lambda (token char)
     (token-update-text token (string char)))
   grid (string->list str)))

(define (update-tokens grid)
  (map
   (lambda (token)
     (token-update token))
   grid))

(define (update-token-pos grid pos)
  (cond 
   ((zero? pos)
    (cons (token-flash (car grid)) (cdr grid)))
   (else (cons (car grid) 
	       (update-token-pos (cdr grid) (- pos 1))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define vg-t 0) 
(define (vg-npush-particles)     
  (set! vg-t (+ vg-t 0.04))     
  (pdata-map!         
   (lambda (p)             
     (let* ((pp (vmul p 0.3))                     
	    (v (vector (- (noise (vx pp) (vy pp) (time)) 0.5)                             
		       (- (noise (vx pp) (+ (vy pp) 112.3) vg-t) 0.5) 0)))
       (vadd (vadd p (vmul v 0.2))                     
	     (vmul (srndvec) 0.005))))         
   "p"))

(define (build-floaty-particles)
  (let ((p (with-state
	    (backfacecull 0)
	    (texture (load-texture "splat.png"))
	    (build-particles 500))))

    (with-primitive 
     p
     (identity)
     (parent scene-root)
     (pdata-add "vel" "v")
     (hint-nozwrite)
     (blend-mode 'src-alpha 'one)
     (pdata-map! (lambda (c) (vector 1 (* (rndf) 0.2) (* (rndf) 0.4))) "c")
     (pdata-map! (lambda (c) (vmul (vector 5 5 5) (rndf))) "s")
     (pdata-map! (lambda (vel) (vmul (srndvec) 0.5)) "vel")
     (pdata-index-map! (lambda (i p) 
			 (vector 0 0 0)) "p"))
    p))

(define part-pos 0)

(define (pdata-submap! fn start count type)
  (cond ((zero? count) 0)
	(else
	 (pdata-set! type (+ start count) (fn (pdata-get type (+ start count))))
	 (pdata-submap! fn start (- count 1) type))))

(define (emit-particles pos)
  (with-primitive 
   particles
   (pdata-submap! 
    (lambda (p) 
      (let ((a (* (rndf) 2 3.141)))
	(vadd pos (vmul (vector (sin a) (cos a) 0) 3))))
    part-pos 80 "p")
   (pdata-submap! 
    (lambda (c) 
      (vector 1 (* (rndf) 0.2) (* (rndf) 0.4)))
    part-pos 80 "c"))
  (set! part-pos (+ part-pos 80)))

(define (update-particles)
  (with-primitive 
   particles
   (vg-npush-particles)
   (pdata-map! (lambda (c) (vmul c 0.99)) "c")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define scene-root (build-locator))

(define c (with-state 
       (parent scene-root) 
       (translate (vector -25.5 -25.5 0)) 
       (build-grid 5 5)))

(define particles (build-floaty-particles))

(osc-source "8000")

(define frame 0)
(define pos 0)

(define (randomise-string src)
  (cond
   ((null? src) "")
   (else (string-append 
      (if (< (random 100) 2)
          (string (choose (string->list "ABCDabcd+-<>?")))
          (string (car src)))
      (randomise-string (cdr src))))))

(define str "?????????????????????????")

(define (render)
  ;;(arloop)

  (update-particles)

    (when (osc-msg "/matrix")
      (set! c (update-grid c (string-append (osc 0) "?????"))))

    (set! c (update-tokens c))
    
    (with-primitive 
        scene-root
        (identity)
        (concat base-transform))

    (when (zero? (modulo frame 40))
      (set! str (randomise-string (string->list str)))
      (set! c (update-grid c str)))
    
    (set! frame (+ frame 1))
    (when (zero? (modulo frame 10))
        (set! c (update-token-pos c pos))
        (set! pos (modulo (+ pos 1) 20)))
    )

(every-frame (render))
