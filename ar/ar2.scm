(require fluxus-018/fluxus-video)
(require fluxus-018/fluxus-artkp)

(clear)
(define base-transform (mtranslate (vector 0 0 0)))

(define (make-token id value switch-t activate-t root prim-list) 
    (list id value switch-t activate-t root prim-list))

(define (token-id t) (list-ref t 0))
(define (token-value t) (list-ref t 1))
(define (token-switch-t t) (list-ref t 2))
(define (token-activate-t t) (list-ref t 3))
(define (token-root t) (list-ref t 4))
(define (token-prim-list t) (list-ref t 5))

; set up a light (using fixed and GLSL lights)
(define lp (vector -50 50 50))
(define l (make-light 'point 'free))
(light-diffuse l (vector 1 1 1))
(light-position l lp)

(define (build-token-prim root value)
    (let ((p  (with-state (parent root)
              ;;(opacity 0.5) 
        (shader "gooch.vert.glsl" "gooch.frag.glsl")
        (shader-set!     (list "LightPos" lp
           "DiffuseColour" (vector 1 1 1)
           "WarmColour" (cond 
                    ((string=? value "a") (vector 1 0 0))
                    ((string=? value "b") (vector 0 1 0))
                    ((string=? value "c") (vector 0 0 1))
                    (else (vector 1 .8 0.5)))
           "CoolColour" (vector 0 0 0.6)
           "OutlineWidth" 0.4))
  
;        (hint-nozwrite)
;        (blend-mode 'src-alpha 'one)
        (cond ((or (string=? value "a") 
                    (string=? value "b") 
                    (string=? value "c") 
                    (string=? value "d"))
                
                (translate (vector 0 2 0))
                (build-sphere 10 10))
            (else
                (let* ((tp (build-extruded-type "Bitstream-Vera-Sans-Mono.ttf" value 1))
                       (r (type->poly tp)))
                    (destroy tp) r))))))
        (with-primitive p
            (apply-transform)
            (pdata-add "pref" "v")
            (pdata-copy "p" "pref"))
        p))

(define (build-token id value x y par)
    (let ((root (with-state 
         (parent par) 
         (translate (vmul (vector x y 0) 1)) 
         (scale 0.1)
         (build-locator))))
        (make-token id value 0 0 root (list (build-token-prim root value)))))

(define (destroy-old l)
    (define (_ l c)
        (cond
            ((null? l) l)
            ((< c 2) (cons (car l) (_ (cdr l) (+ c 1))))
            (else
                (destroy (car l))
                (_ (cdr l) (+ c 1)))))
    (_ l 0))

(define (token-update t dt new-value pos)
    (make-token
        (token-id t)
        new-value
        (if (string=? new-value (token-value t))
            (min 1 (+ (token-switch-t t) dt))
            0)
        (if (and (zero? (token-activate-t t)) (eq? pos (token-id t)))
            1
            (max 0 (-  (token-activate-t t) dt)))
        (token-root t)
        (if (not (string=? new-value (token-value t)))
            (destroy-old (cons (build-token-prim (token-root t) new-value) (token-prim-list t)))
            (if (and (> (length (token-prim-list t)) 1) (eq? t 1))
                (begin
                    (destroy (cadr (token-prim-list t)))
                    (list (car (token-prim-list t))))
                (token-prim-list t)))))

(define (token-render t)
    (with-primitive 
        (car (token-prim-list t))
        (identity)
        (scale (token-switch-t t))
        (when (not (zero? (token-activate-t t)))
        (pdata-map! 
            (lambda (p pref) 
                (vadd pref (vmul (srndvec) (token-activate-t t)))) 
        "p" "pref"))
    
        )
    (when (> (length (token-prim-list t)) 1)
        (with-primitive 
            (cadr (token-prim-list t))
            (identity)
            (scale (- 1 (token-switch-t t))))))


(define (build-token-line id x y par)
    (cond 
        ((zero? x) '())
        (else 
            (cons (build-token id "A" x y par) 
                (build-token-line (- id 1) (- x 1) y par)))))

(define (build-token-grid id x y par)
    (cond 
        ((zero? y) '())
        (else 
            (append (build-token-line id x y par) 
                (build-token-grid (- id x) x (- y 1) par)))))

(define (update-token-grid tokens text pos)
    (let ((i -1))
        (map
            (lambda (token)
                (set! i (+ i 1))
                (token-update token (delta) (string (string-ref text i)) pos))
            tokens)))


(camera-clear-cache)
(camera-list-devices)

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


(define (arloop)
  ;; get next frame from camera
  (camera-update cam)
  (when #t ;;(key-pressed " ") 
    ;; detect the markers in the image 
    (let ([marker-count (ar-detect (camera-imgptr cam))])
      ;; get the modelview matrix of each marker and draw
      ;; a cube on the marker
      (printf "detected markers: ~a~n" marker-count)
      (for ([i (in-range marker-count)])
           ;; scale it up to pattern width (80mm)
           (let ([m (mmul (ar-get-modelview-matrix i) (mscale (vector 80 80 80)))]
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
            ;; move the cube center up by half to match the marker
            (translate #(0 0 .5))
            (draw-cube))))))))


(clear-colour (vector 0.2 0.2 0.2))

(define root (build-locator))
;;(define t (build-token-grid 19 5 4 root))

(define l1 "ab.cB")
(define l2 "<.+D-")
(define l3 "aaaaa")
(define l4 "> cdd")

(define tokens (list #\a #\b #\c #\d
        #\A #\B #\C #\D    
        #\+ #\- #\< #\>
        #\. #\space  #\[ #\]))

(define (choose l) (list-ref l (random (length l))))

(define mut-rate 0.02)

(define (strmut str)
    (list->string
        (map
            (lambda (c)
                (if (< (rndf) mut-rate) (choose tokens) c))
            (string->list str))))

(define (mutate)
    (when (< (rndf) mut-rate) (set! l1 (strmut l1)))
    (when (< (rndf) mut-rate) (set! l2 (strmut l2)))
    (when (< (rndf) mut-rate) (set! l3 (strmut l3)))
    (when (< (rndf) mut-rate) (set! l4 (strmut l4))))

(define pos 0)
(define frame 0)

(define particles
  (with-state
   (parent root)
   (translate (vector 2.5 2.5 0))
   (colour (vector 0.1 0.1 0.1))
   (texture (load-texture "splat.png"))
   (build-particles 500)))


(with-primitive particles
        (pdata-add "vel" "v")
        (hint-nozwrite)
        (blend-mode 'src-alpha 'one)
        (pdata-map! (lambda (c) (vector 1 (* (rndf) 0.2) (* (rndf) 0.4))) "c")
        (pdata-map! (lambda (c) (vmul (vector 0.5 0.5 0.5) (rndf))) "s")
        (pdata-map! (lambda (vel) (vmul (srndvec) 0.005)) "vel")
        (pdata-index-map! (lambda (i p) 
                    (let ((a (* 2 (/ i 500) 3.141)))
                      (vector (sin a) (cos a) 0)))
                  "p"))


(define (init-particles)
(with-primitive particles
        (pdata-index-map! (lambda (i p) 
                    (let ((a (* 2 (/ i 500) 3.141)))
                      (vector (sin a) (cos a) 0)))
                  "p")))

(define (init-particles2)
(with-primitive particles
        (pdata-index-map! (lambda (i p) 
                    (let ((a (* 2 (/ i 500) 3.141)))
                      (vector (sin (* a 2)) (cos (* a 3)) (sin a))))
                  "p")))

(define (init-particles3)
(with-primitive particles
        (pdata-index-map! (lambda (i p) 
                    (let ((a (* 2 (/ i 500) 3.141)))
                      (vector (sin (* a 2)) (sin a) (cos (* a 3)))))
                  "p")))


(define (render)
  (arloop)
  (when (key-pressed "p") (init-particles))
  (when (key-pressed "o") (init-particles2))
  (when (key-pressed "l") (init-particles3))
  ;; (when (key-pressed "p") (set! c "B"))
  (mutate)
;;    (set! t (update-token-grid t (string-append l1 l2 l3 l4) pos))

  (with-primitive particles
          (pdata-map! (lambda (p vel) (vadd p vel)) "p" "vel"))
  
  (with-primitive 
   root
   (identity)
   (concat base-transform)
   (translate (vector -2.5 -2.5 0)))


  
;;  (for-each
;;   (lambda (token)
;;     (token-render token))
;;   t)
  
  (set! frame (+ frame 1))
  (when (zero? (modulo frame 10)) (set! pos (modulo (+ pos 1) 20)))
  )    

(every-frame (render))


