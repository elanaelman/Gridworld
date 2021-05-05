; Elana's gridworld functions.

;temporary map:
(def-roadmap '(home office) '((p1 home 1 office))) 

;temporary function, included in skeleton:

(defun answer_to_whq? (wff)
	(check-whq-answer-in-kb 'NIL wff (state-node-wff-htable *curr-state-node*))
)

;objects:

(def-object 'person '(can_talk is_animate))
(def-object 'note '(is_readable))

(place-object 'AG 'person 'home 0  
    nil ;no associated things
	'(
	  ;self-knowledge
	  (is_tired_to_degree AG 0)
	  (is_hungry_to_degree AG 0)
	  (has_money AG 100)
	  (has_age AG 25) 
	  (has_name AG Alex)
	  (has_job AG employee)
	  (works_at AG office)
	  (is_single AG)
	  ;other knowledge

	  ;depends on Boss object:
	  ;(has_name Boss Carol) (has_job Boss employer) (works_at Boss office)
	 )
	 nil ;propositional attitudes?
	 )

;(place-object 'Boss 'person 'boss-home 0
;	nil
;	'(
;	  ;self-knowledge
;	  (is_tired_to_degree Boss 0)
;	  (is_hungry_to_degree Boss 0)
;	  (has_money Boss 200)
;	  (has_age Boss 30)
;	  (has_name Boss Carol)
;	  (has_job Boss employer)
;	  (works_at Boss office)
;	  (is_single Boss)
;      ;other knowledge
;	  (has_name AG Alex)
;	  (has_job AG employee)
;	  (works_at AG office)
;	)
;	nil)


;actions:

(defun has_money? (?ag)
	(let ((ans (answer_to_whq? (list 'has_money ?ag '?x))))
		(if (equal (car ans) 'not) -1 (caddar ans))))

(setq buy
	  (make-op
		:name 'buy
		:pars '(?item ?cost)
		:preconds '((is_at AG supermarket) 
					(sells supermarket ?item ?cost)	
					; ^ Add knows that ... and person to ask prices
					(>= (has_money? AG) ?cost))
		:effects '((has_money AG (- (has_money? AG) ?cost) (has AG ?item)))
		:time-required 1
		:value '?cost
	  )
)

(setq buy.actual
	  (make-op.actual
		:name 'buy.actual
		:pars '(?item ?store ?cost)
		:startconds '((is_at AG ?store) 
					  (sells ?store ?item ?cost)
					  (>= (has_money? AG) ?cost))
		:stopconds nil
		:deletes '((has_money AG (has_money? AG)))
		:adds '((has_money AG (- (has_money? AG) ?cost)) (has AG ?item))
	  )
)

(setq smell 
	  (make-op 
		:name 'smell
		:pars '(?item)
		:preconds '((has AG ?item) (is_food ?item))
		:effects '((knows AG (whether (is_expired ?item)))) ;TODO: check this
		:time-required '1
		:value '(if (expired? ?item) 0.5 -0.5) ;TODO: expired?
	  )
)

(setq smell.actual
	  (make-op.actual
		:name 'smell.actual
		:pars '(?item)
		:startconds '((has AG ?item) (is_food ?item))
		:stopconds nil
		:deletes nil
		:adds '((knows AG (whether (is_expired ?item))))
	  )
)

;might need to add case for no message found.
(defun message_of? (n)
	(caddar (answer_to_whq? (list 'has_message_that n '?message))))

(setq read
	  (make-op
		:name 'read
		:pars '(?item ?location)
		:preconds '((is_at AG ?location) (is_at ?item ?location) (is_readable ?item))
		:effects '(knows AG (message_of? ?item))
		:time-required 3
		:value 0
	  )
)


(setq read.actual
	  (make-op.actual
		:name 'read.actual
		:pars '(?item ?location)
		:startconds '((is_at AG ?location) (is_at ?item ?location) (is_readable ?item))
		:stopconds '((there_is_a_fire))
		:deletes nil
		:adds '(knows AG (message_of? ?item))
	  )
)

;Example of a readable item
(place-object 'note1 'note 'home 0 nil '((has_message_that note1 (wants Alice apple1))) nil)


; say operators are currently broken, and also not useful without a second agent

;(setq say
;	  (make-op
;		:name 'say
;		:pars '(?message ?location)
;		:preconds '((is_at AG ?location))
;		:effects '((said AG ?message ?location (current_time?)))
;		:time-required 2
;		:value 0
;	  )
;)

;(setq say.actual
;		(make-op.actual
;		  :name 'say.actual
;		  :pars '(?message ?location)
;		  :startconds '((is_at AG ?location))
;		  :stopconds '((there_is_a_fire))
;		  :deletes nil
;		  :adds '((said AG ?message ?location (current_time?)))
;		)
;)




;setup:

(setq *operators* '(buy read smell say))

(setq *search-beam* (list (cons 1 *operators*)))


