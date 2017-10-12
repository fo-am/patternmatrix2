(require fluxus-018/fluxus-video)
(require fluxus-018/fluxus-artkp)

(clear)

(define base-transform (mtranslate (vector 0 0 0)))

(camera-clear-cache)
(camera-list-devices)

;; check the device id's in the console and change the first parameter of
;; camera-init to the id
(define cam (camera-init 0 800 600))

;; init the ar system with the camera resolution and the camera parameter file
(ar-init (camera-width cam) (camera-height cam) "data/camera_para.dat")

;; enable automatic threshold calculation to adapt to different lighting conditions
(ar-auto-threshold #t)

;;(set-projection-transform (ar-get-projection-matrix))
;;(set-camera-transform (mident))

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

(define pos 0)
(define frame 0)

;;;;;;;;;;;;;;;;;;;;;;;;

(define (build-circle)
    (let ((p
                (with-state
                    (hint-unlit)
                    (parent root)
                    (translate (vector 2.5 2.5 0))
                    (colour (vector 1 1 0))
                    (texture (load-texture "textures/rainbow.png"))
                    (build-ribbon 30))))
        
        
        (with-primitive p
            (pdata-add "vel" "v")
            (hint-nozwrite)
            (blend-mode 'src-alpha 'one)
            (pdata-map! (lambda (c) (vector 1 (* (rndf) 0.2) (* (rndf) 0.4))) "c")
            (pdata-map! (lambda (c) (vmul (vector 0.5 0.5 0.5) (rndf))) "s")
            ;(pdata-index-map! (lambda (i vel)
            ;            (let ((a (* 2 (/ i 30) 3.141))) 
            ;            (vmul (vector (cos a) (sin a) 0) 0.05))) "vel")
            (pdata-map! (lambda (w) 0.1) "w")
            (pdata-index-map! (lambda (i p) 
                    (let ((a (* 2 (/ i (pdata-size)) 3.141)))
                        (vector (sin a) (cos a) 0)))
                "p"))
        p))


(define (init-ribbon ribbon)
    (with-primitive ribbon
        (pdata-index-map! (lambda (i p) 
                (let ((a (* 2 (/ i (- (pdata-size) 1)) 3.141)))
                    (vector (sin a) (cos a) 0)))
            "p")))

(define ribbon (build-circle))
(define ribbon2 (with-state (translate (vector 0 0 0.1)) (build-circle)))

;;;;;;;;;;;;;;;;;;;


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
                (let ((a (* 2 (/ i (pdata-size)) 3.141)))
                    (vector (sin a) (cos a) 0)))
            "p"))
    (with-primitive ribbon
        (pdata-index-map! (lambda (i p) 
                (let ((a (* 2 (/ i (pdata-size)) 3.141)))
                    (vector (sin a) (cos a) 0)))
            "p")))

(define (init-particles2)
    (with-primitive particles
        (pdata-index-map! (lambda (i p) 
                (let ((a (* 2 (/ i (pdata-size)) 3.141)))
                    (vector (sin (* a 2)) (cos (* a 3)) (sin a))))
            "p"))
    (with-primitive ribbon
        (pdata-index-map! (lambda (i p) 
                (let ((a (* 2 (/ i (pdata-size)) 3.141)))
                    (vector (sin (* a 2)) (cos (* a 3)) (sin a))))
            "p")))

(define (init-particles3)
    (with-primitive particles
        (pdata-index-map! (lambda (i p) 
                (let ((a (* 2 (/ i (pdata-size)) 3.141)))
                    (vector (sin (* a 2)) (sin a) (cos (* a 3)))))
            "p")))


(define (render)
    ;;  (arloop)
    (when (key-pressed "p") (init-particles))
    (when (key-pressed "o") (init-particles2))
    (when (key-pressed "l") (init-particles3))
    
    (with-primitive particles
        (pdata-map! (lambda (p vel) (vadd p vel)) "p" "vel"))
    
    (with-primitive ribbon
        (pdata-map! (lambda (p vel) (vadd p vel)) "p" "vel"))
    
    (with-primitive 
        root
        (identity)
        (concat base-transform)
        (translate (vector -2.5 -2.5 0)))
    
    (set! frame (+ frame 1))
    (when (zero? (modulo frame 10)) (set! pos (modulo (+ pos 1) 20)))
    )    

(every-frame (render))


