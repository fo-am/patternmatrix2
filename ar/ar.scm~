(require fluxus-018/fluxus-video)
(require fluxus-018/fluxus-artkp)

(clear)
(camera-clear-cache)
(camera-list-devices)

(define corner-obj (with-state (hide 1) (load-primitive "models/corner.obj")))

(define (draw-corner d)
    (with-state
        (translate (vector 0 0 d))
        (draw-instance corner-obj)))

(define (draw-corner-cube d)
  (with-state
    (scale 0.5)

   (draw-corner d)
   (rotate (vector 90 0 0))
   (draw-corner d)
   (rotate (vector 90 0 0))
   (draw-corner d)
   (rotate (vector 90 0 0))
   (draw-corner d)

   (rotate (vector 0 180 0))

   (draw-corner d)
   (rotate (vector 90 0 0))
   (draw-corner d)
   (rotate (vector 90 0 0))
   (draw-corner d)
   (rotate (vector 90 0 0))
   (draw-corner d)))

(define (render-row row p pos)
  (let ((row (string->list row)))
    (with-state
     (for-each
      (lambda (i)
    (with-state
     (scale 2)
     (when (eq? pos p) (colour (vector 1 0 0)))
     (cond
      ((equal? i #\.) 
       (with-state (scale 0.5) (draw-sphere)))
      (else (draw-corner-cube (if (eq? pos p) -0.5 0)))))
    (translate (vector 8.5 0 0))
    (set! p (+ p 1)))
      row))))

(define (render-grid pat pos)
  (let ((p 0))
    (with-state
     (scale 10)
     (translate (vector (* 2 -8.5) (* 2 8.5) 0.5))
     (rotate (vector 90 0 0))
     (for-each
      (lambda (row)
    (render-row row p pos)
    (translate (vector 0 0 8.5))
    (set! p (+ p 5)))
      pat))))




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

(define base-transform (mtranslate (vector 0 0 910)))

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
           (let ([m (ar-get-modelview-matrix i)]
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
            ;; scale it up to pattern width (80mm)
            (scale 80)
            ;; move the cube center up by half to match the marker
            (translate #(0 0 .5))
            (draw-cube))))))))



(define pat '("abcd." "A+B+C" "....." "....."))

(define pos 0)
(define frame 0)


(define (render)
  (arloop)
  (with-state
   (concat base-transform)
   (render-grid pat pos))

  (when (zero? (modulo frame 10)) (set! pos (modulo (+ pos 1) 20)))
  (set! frame (+ frame 1)))

(every-frame (render))
