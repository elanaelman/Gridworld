; Elana's gridworld functions.

(def-roadmap '(me-home boss-home office) '((path1 me-home 2 office) (path2 boss-home 3 office)))


;objects:

(def-object 'person '(can_walk can_talk can_give can_take is_animate))

(place-object 'ME 'person 'me-home 0  
    nil ;no associated things
	'(
	  ;self-knowledge
	  (is_tired_to_degree ME 0)
	  (is_hungry_to_degree ME 0)
	  (has_money ME 100)
	  (has_age ME 25) 
	  (has_name ME Alex)
	  (has_job ME employee)
	  (works_at ME office)
	  (is_single ME)
	  ;other knowledge
	  (has_name Boss Carol) (has_job Boss employer) (works_at Boss office)
	 )
	 nil ;propositional attitudes?
	 )

(place-object 'Boss 'person 'boss-home 0
	nil
	'(
	  ;self-knowledge
	  (is_tired_to_degree Boss 0)
	  (is_hungry_to_degree Boss 0)
	  (has_money Boss 200)
	  (has_age Boss 30)
	  (has_name Boss Carol)
	  (has_job Boss employer)
	  (works_at Boss office)
	  (is_single Boss)
      ;other knowledge
	  (has_name ME Alex)
	  (has_job ME employee)
	  (works_at ME office)
	)
	nil)


;actions:

(setq buy
	  (make-op
		:name 'buy
		:pars '(?item ?store ?cost)
		:preconds '((is_at AG ?store) 
					(sells ?store ?item ?cost) ;need sells? check property?
					(has_money AG ?cost))
		:effects '((has_money AG (- (money? AG) ?cost) (owns AG ?item))) ;need owns, money?
		:time-required '1
		:value '0 ;value of item? idk
	  )
)

(setq buy.actual
	  (make-op.actual
		:name 'buy.actual
		:pars '(?item ?store ?cost)
		:startconds '((is_at AG ?store) 
					  (sells ?store ?item ?cost) ;need sells? check property?
					  (has_money AG ?cost))
		:stopconds nil
		:deletes nil
		:adds '((has_money AG (- (money? AG) ?cost)) (owns AG ?item))

		;elapsed time?
	  )
)

(setq smell 
	  (make-op 
		:name 'sleep
		:pars '(?item)
		:preconds '((owns AG ?item) (is_food ?item))
		:effects '((knows AG (whether (is_expired ?item))))
		:time-required '1
		:value '(if (is_expired ?item) '1 '-1)
	  )
)

(setq smell.actual
	  (make-op.actual
		:name 'smell.actual
		:pars '(?item)
		:startconds '((owns AG ?item) (is_food ?item))
		:stopconds nil
		:deletes nil
		:adds '((knows AG (whether (is_expired ?item))))
	  )
)

(setq read
	  (make-op
		:name 'read
		:pars '(?item ?location)
		:preconds '((is_at AG ?location) (is_at ?item ?location))
		:effects '(knows AG (message_in ?item))
		:time-required '(* 0.5 (length_of (message_in ?item)))
		:value '0
	  )
)

(setq read.actual
	  (make-op.actual
		:name 'read.actual
		:pars '(?item ?location)
		:startconds '((is_at AG ?location) (is_at ?item ?location))
		:stopconds '((there_is_a_fire))
		:deletes nil
		:adds '(knows AG (message_in ?item))
	  )
)

(setq say
	  (make-op
		:name 'say
		:pars '(?message ?location)
		:preconds (is_at AG ?location)
		:effects '((said AG ?message ?location (current_time))) ;time?
		:time-required '(*0.5 (length_of ?message))
		:value '0
	  )
)

;setup:

(setq *operators* '(buy read smell say))

(setq *search-beam* (list (cons 1 *operators*)))


