
(DEFUN check (li i)
       (COND
	 ((>= i (length li)) T)
	 (T (COND
	      ((= (car li) (nth i li)) NIL)
	      ((= (abs (- (car li) (nth i li))) i) NIL)
	      (T (check li (+ i 1))) 
	    )
	 )
       )
)
	 

(DEFUN nqueen (li row col)
       (COND
	 ((> row 4) (print li))
	 ((> col 4) NIL)
	 (T (COND
	      ((check (cons col li) 1) (progn
					 (nqueen (cons col li) (+ row 1) 1) 
					 (nqueen li row (+ col 1))
			  	       )
	      )
	      (T (nqueen li row (+ col 1)))
	    )
	 )
       )
)

(nqueen '() 1 1)
