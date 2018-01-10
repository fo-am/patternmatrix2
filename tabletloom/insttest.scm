(clear-colour (vector 1 1 1))

;;(define a (build-cube))
(define b (load-obj "models/rr-a.obj"))

(with-primitive b
		(pdata-map! (lambda (n) (vmul n -1)) "n"))

(load-obj "models/rr-b.obj")
(load-obj "models/rr-c.obj")
(load-obj "models/rr-d.obj")
  
(with-state
 (translate (vector 1 0 0))
 (build-instance b))

