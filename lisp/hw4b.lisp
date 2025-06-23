(DEFUN insertion_sort (li1 li2)
       (print (append li1 li2))
       (COND
	 ((> (length li2) 0) (insertion_sort (insert li1 (- (length li1) 1) (car li2)) (cdr li2)))
	 (T NIL)
       )
)

(DEFUN insert (li i a)
	(COND
	  ((= i -1) (cons a li))
	  ((> (nth i li) a) (insert li (- i 1) a))
	  ((<= (nth i li) a) (append 
			       (subseq li 0 (+ i 1)) 
			       (list a) 
			       (COND
				 ((= i (- (length li) 1)) '())
				 (T (subseq li (+ i 1) (length li)))
			       )
			     )
	  )
	)
)

(princ "TC1:")
(insertion_sort '() '(11 33 23 45 13 25 8 135))
(terpri)
(princ "TC2:")
(insertion_sort '() '(83 72 65 54 47 33 29 11))
