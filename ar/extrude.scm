; an example of the fluxus extrusion tool


(require fluxus-018/shapes)

;; t is a value that goes from 0 to 1 to interpolate in a C1 continuous way across uniformly sampled data points.
;; when t is 0, this will return B.  When t is 1, this will return C.
(define (cubic-hermite A B C D t)
    (let ((a (+ (- (+ (/ (- A) 2) (/ (* 3 B) 2)) (/ (* 3 C) 2)) (/ D 2)))
            (b (+ (- A (/ (* 5 B) 2)) (- (* 2 C) (/ D 2))))
            (c (+ (/ (- A) 2) (/ C 2))))
        (+ (* a t t t) (* b t t) (* c t) B)))


(clear)
(clear-colour 0.5)

(define (extrude profile width path prim t state) 
    (list profile width path prim t state))
(define (extrude-profile p) (list-ref p 0))
(define (extrude-width p) (list-ref p 1))
(define (extrude-path p) (list-ref p 2))
(define (extrude-prim p) (list-ref p 3))
(define (extrude-t p) (list-ref p 4))
(define (extrude-state p) (list-ref p 5))

(define extrude-points 100)

(define (build-extrude a b c d)
    (let ((profile (build-circle-points 12 0.5))
            (width (build-list extrude-points
                    (lambda (n) 0.1)))
            (path (build-list extrude-points
                    (lambda (n) (vector 
                            (cubic-hermite (vx a) (vx b) (vx c) (vx d) (/ n 100))
                            (cubic-hermite (vy a) (vy b) (vy c) (vy d) (/ n 100))
                            (cubic-hermite (vz a) (vz b) (vz c) (vz d) (/ n 100)))))))
        (extrude profile width path
            (with-state
                (wire-colour 0)
                (colour (vector 1 1 1))   
                (specular (vector 1 1 1))
                (shinyness 20)
                (hint-wire)
                (build-partial-extrusion profile path 10)) 0 'growing)))

(define (update-extrude e)
    (if (< (extrude-t e) 1)
        (with-primitive (extrude-prim e)
            (partial-extrude 
                (if (eq? (extrude-state e) 'growing)
                   (* (extrude-t e) (length (extrude-path e)))
                   (* (- 1 (extrude-t e)) (length (extrude-path e))))
                (extrude-profile e) 
                (extrude-path e)
                (extrude-width e)
                (vector 0 1 0) 0.05)
            (extrude 
                (extrude-profile e) 
                (extrude-width e)
                (extrude-path e)
                (extrude-prim e) 
                (+ (extrude-t e) 0.01)
                (extrude-state e)))
        e))

(define (extrude-new-path e a b c d)
    (extrude 
        (extrude-profile e) 
        (extrude-width e)
        (build-list extrude-points
            (lambda (n) (vector 
                    (cubic-hermite (vx a) (vx b) (vx c) (vx d) (/ n extrude-points))
                    (cubic-hermite (vy a) (vy b) (vy c) (vy d) (/ n extrude-points))
                    (cubic-hermite (vz a) (vz b) (vz c) (vz d) (/ n extrude-points)))))
        (extrude-prim e) 
        0
        'growing))

(define (extrude-ungrow e)
    (extrude 
        (extrude-profile e) 
        (extrude-width e)
        (extrude-path e)
        (extrude-prim e) 
        0
        'ungrowing))


(with-state
    (translate (vector 0 0 0)) 
    (build-cube))

(with-state
    (translate (vector 5 0 0)) 
    (build-cube))

(define e (build-extrude 
        (vector 0 10 0) (vector 0 0 0) 
        (vector 5 0 0) (vector 10 10 0)))


(every-frame (set! e (update-extrude e)))

(set! e (extrude-new-path e (vector 0 10 0) (vector 0 0 0)
            (vector 0 0 5) (vector 0 10 5)))


;;(set! e (extrude-ungrow e))

