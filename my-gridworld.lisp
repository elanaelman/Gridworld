; Our gridworld.

;;Zag's code
(def-object 'robot '(is_animate can_talk))
(def-object 'office '(is_inanimate))
(def-object 'gas '(is_inanimate is_notedible can_finish (has_cost 2.0)))
(def-object 'pizza '(is_edible can_finish (has_cost 3.0)))
(def-object 'juice '(is_potable can_finish (has_cost 2.0)))
(def-object 'sushi '(is_edible can_finish (has_cost 5.0)))
(def-object 'car '(is_inanimate is_robots has_gaslevel has_speed has_mileagelevel))

(def-roadmap '(home work supermarket gasstation dropoffLoc) 
	'((path1 home 3 supermarket) (path2 home 5 work) (path3 home 4 dropoffLoc)
	  (path4 work 2 supermarket) (path5 work 4 gasstation)
	  (path6 supermarket 2 gasstation) (path7 supermarket 3 dropoffLoc)
	  (path8 dropoffLoc 4 gasstation)))
	  
(place-object 'pizza3 'pizza 'home 0 
	nil ; no associated-things
	; current facts
	'((is_edible pizza3) (can_finish pizza3)
	 )
    nil ; propositional attitudes
)

(place-object 'juice3 'juice 'plaza 0 
	nil ; no associated-things
	; current facts
	'((is_potable juice3) (can_finish juice3)
	 )
    nil ; propositional attitudes
)

(place-object 'pizza1 'pizza 'supermarket 0 
	nil ; no associated-things
	; current facts
	'((is_edible pizza1) (has_cost 3.0) 
	 )
    nil ; propositional attitudes
)

(place-object 'juice1 'juice 'supermarket 0 
	nil ; no associated-things
	; current facts
	'((is_potable juice1) (has_cost 2.0)
	 )
    nil ; propositional attitudes
)
(place-object 'sushi1 'sushi 'supermarket 0 
	nil ; no associated-things
	; current facts
	'((is_edible sushi1) (has_cost 5.0)
	 )
    nil ; propositional attitudes
)

(place-object 'car1 'car 'home 0 
	nil ; no associated-things
	'((is_inanimate car1) (is_robots car1) (has_speed car1 0.0) (mileage_left car1 250)
	 )
    nil ; propositional attitudes
)	

;;Model for sleep
(setq sleep
	(make-op
		:name ’sleep
		:pars ’(?f ?h)
		:preconds ’( (is_at AG home)
			(is_tired_to_degree AG ?f)
			(>= ?f 0.5)
			(is_hungry_to_degree AG ?h)
			(> ?f ?h)
			(not (there_is_a_fire)) )
		:effects ’( (is_tired_to_degree AG 0)
			(not (is_tired_to_degree AG ?f))
			(is_hungry_to_degree AG (+ ?h 2)))
		:time-required ’(* 4 ?f)
		:value ’(* 2 ?f)
	)
)

(setq sleep.actual 
	(make-op.actual 
		:name ’sleep.actual 
		:pars ’(?f ?h)                                           	   
    		:startconds '((is_at AG home)
                  	(is_tired_to_degree AG ?f)
                  	(>= ?f 2.5)
                  	(is_hungry_to_degree AG ?h)
                  	(> ?f ?h) ); more tired than hungry
    		:stopconds ’((there_is_a_fire)
    			(is_tired_to_degree AG 0.0))
    		:deletes '((is_tired_to_degree AG ?#1) 
               		(is_hungry_to_degree AG ?#2))
    		:adds ’((is_tired_to_degree AG (- ?f (* 0.5 (elapsed_time?))))
            	(is_hungry_to_degree AG (+ ?h (* 0.25 (elapsed_time?)))) ) 
    )
)

;;Model for Pick Up
(setq pick_up
	(make-op
		:name ’pick_up
		:pars ’(?b ?x ?w ?h ?f)
		:preconds ’( (<= ?w 5)
			(not (is_holding_something AG))
			(is_tired_to_degree AG ?f)
                  	(<= ?f 1.5)
                  	(is_hungry_to_degree AG ?h)
		         )
		:effects ’((is_holding AG ?b) (is_holding_something AG)
			(is_tired_to_degree AG (+ ?f 1))
			(is_hungry_to_degree AG (+ ?h 0.5)))
		:time-required ’(* 1 ?f)
		:value ’(- 1 ?f)
	)
)

(setq pick_up.actual 
	(make-op
		:name ’pick_up.actual
		:pars ’(?b ?x ?w ?h ?f)
		:startconds ’( (<= ?w 5)
			(not (is_holding AG *))
			(is_tired_to_degree AG ?f)
                  	(<= ?f 1.5)
                  	(is_hungry_to_degree AG ?h)
		         )
		:stopconds ’((is_holding_something AG))
		:deletes ’((is_tired_to_degree AG ?#1) 
               		(is_hungry_to_degree AG ?#2))
		:adds ’((is_tired_to_degree AG (- ?f (* 0.5 (elapsed_time?))))
            	(is_hungry_to_degree AG (+ ?h (* 0.15 (elapsed_time?)))) 
		(is_holding AG ?b) (is_holding_something AG)) 
	)
)

;;Model for Put down
(setq put_down
	(make-op
		:name ’put_down
		:pars ’(?b ?x ?f)
		:preconds ’((is_holding AG ?b)
				(can_hold ?x ?b))
		:effects ’((is_on ?b ?x)
			(is_tired_to_degree AG (- ?f 1))
			)
		:time-required ’(* 1 ?f)
		:value ’(+ 1 ?f)
	)
)
(setq put_down.actual
	(make-op
		:name ’put_down.actual
		:pars ’(?b ?x ?f)
		:startconds ’( ((is_holding AG ?b)
				(can_hold ?x ?b))
		:stopconds ’( (not(can_hold ?x ?b))
				)
		:deletes ’((is_tired_to_degree AG ?#1) )
		:adds ’((is_tired_to_degree AG (- ?f (* 0.5 (elapsed_time?))) (is_on ?b ?x) (not (is_holding AG ?b)))
            	 ) 
)
	 
;;Model for Push
(setq push
	(make-op
		:name ’push
		:pars ’(?b ?x ?y ?h ?f)
		:preconds ’((is_at ?b ?x)
			(not (is_same ?x ?y))
		         )
		:effects ’((is_at ?b ?y)
			(is_tired_to_degree AG (+ ?f 2))
			(is_hungry_to_degree AG (+ ?h 1)))
		:time-required ’(* 2 ?f)
		:value ’(- 1 ?f)
	)
)

(setq push.actual
	(make-op
		:name ’push.actual
		:pars ’(?b ?x ?y)
		:startconds ’((is_at ?b ?x)
			(not (is_same ?x ?y))
		         )
		:stopconds ’((is_tired_to_degree AG (> ?f 2))
			(is_hungry_to_degree AG (> ?h 2)))
		:deletes ’((is_tired_to_degree AG ?#1) 
               		(is_hungry_to_degree AG ?#2))
		:adds ’((is_tired_to_degree AG (- ?f (* 0.5 (elapsed_time?))))
            	(is_hungry_to_degree AG (+ ?h (* 0.25 (elapsed_time?)))) (is_at ?b ?x)) 
	)
	
)

;;----------------------------------------

;;George's code
;;model version of eat
(setq eat 
	(make-op :name 'eat :pars '(?h ?x ?y) ; level of hunger ?h
	:preconds '( (is_hungry_to_degree AG ?h) 
				 (>= ?h 2.0)
				 (is_at AG ?y) 
				 (is_at ?x ?y) 
				 (is_edible ?x) 
				 (knows AG (whether (is_edible ?x)))
				 (not (there_is_a_fire))
                 (not (there_is_a_flood)) )
	:effects '( (is_hungry_to_degree AG 0.0) 
				(not (is_hungry_to_degree AG ?h)) )
	:time-required 1
	:value '(* 2 ?h)
	)
)

;;actual version of eat
(setq eat.actual 
	(make-op.actual :name 'eat.actual :pars '(?h ?x ?y)
	:startconds '( (is_hungry_to_degree AG ?h) 
				   (>= ?h 2.0)
				   (is_at AG ?y) 
				   (is_at ?x ?y) 
				   (is_edible ?x) 
				   (knows AG (whether (is_edible ?x))) )
	:stopconds '( (there_is_a_fire)
				  (there_is_a_flood) 
				  (is_hungry_to_degree AG 0.0) )
	:deletes '( (is_hungry_to_degree AG ?#1) )
	:adds '( (is_hungry_to_degree AG 0.0) )
	)
)


;; model version of sleep
(setq drink 
	(make-op :name 'drink :pars '(?h ?x ?y) ; level of thirst ?h
	:preconds '( (is_thirsty_to_degree AG ?h) 
				 (> ?h 0.0)
				 (is_at AG ?y) 
				 (is_at ?x ?y) 
				 (is_potable ?x) 
				 (knows AG (whether (is_potable ?x))) 
				 (not (there_is_a_fire))
                 (not (there_is_a_flood)) )
	:effects '( (is_thirsty_to_degree AG 0.0) 
				(not (is_thirsty_to_degree AG ?h)) )
	:time-required 1
	:value '(* 2 ?h)
	)
)

;; actual drink operation
(setq drink.actual 
	(make-op.actual :name 'drink.actual :pars '(?h ?x ?y)
	:startconds '( (is_thirsty_to_degree AG ?h) 
				   (> ?h 0.0)
				   (is_at AG ?y) 
				   (is_at ?x ?y) 
				   (is_potable ?x) 
				   (knows AG (whether (is_potable ?x))) )
	:stopconds '( (there_is_a_fire)
				  		(there_is_a_flood) 
				  		(is_thirsty_to_degree AG 0.0) )
	:deletes '( (is_thirsty_to_degree AG ?#1) )
	:adds '( (is_thirsty_to_degree AG 0.0) )
	)
)

;;model of walk
(setq walk 
	(make-op :name 'walk :pars '(?x ?y ?z ?f)
	:preconds '((is_at AG ?x)        
				(is_on ?x ?z)        
				(is_on ?y ?z) (point ?y)
				(navigable ?z)
                (is_tired_to_degree AG ?f) )
    :effects '((is_at AG ?y) 
    		   (not (is_at AG ?x))
               ;(is_tired_to_degree AG (+ ?f 0.5))
               (is_tired_to_degree AG (+ ?f (* 0.5 (distance_from+to+on? ?x ?y ?z))))  
               (not (is_tired_to_degree AG ?f)) )
    :time-required '(distance_from+to+on? ?x ?y ?z)
    :value '(- 3 ?f)
    )
)

;; helper function to calculate distance
(defun distance_from+to+on? (x y z)
	(let	(result pt1 pt2 units index1 index2 str)
			; If both x and y are named road points, simply do a look-up.
		(if (and (evalFunctionPredicate (cons 'point (list x))) (evalFunctionPredicate (cons 'point (list y))))
			(dolist (triple (get x 'next))
				(when (and (eq z (first triple)) (eq y (second triple)))
					(setq result (third triple))
					
					(return-from distance_from+to+on? result)
				)
			)	
			; Otherwise, x is of the form (the_pt+units_from+towards+on_road? ?d ?a ?b ?r), 
			; and parse the result to get the distance.
			(progn
				(if (atom x)
					(setq str (string x))
					(setq str (apply (car x) (cdr x))); (string x))
				)
				(setq index1 (search "PT_" str))
				(setq index2 (search "_UNITS" str))
				(setq units (parse-integer (subseq str (+ index1 3) index2)))
				(setq index1 (search "FROM_" str))
				(setq index2 (search "_TOWARDS" str))
				(setq pt1 (INTERN (string-upcase (subseq str (+ index1 5) index2))))
				(setq index1 (+ index2 9))
				(setq index2 (search "_ON" str))
				(setq pt2 (INTERN (string-upcase (subseq str index1 index2))))
				(if (and (eq pt1 x) (eq pt2 y))
					(return-from distance_from+to+on? (- (distance_from+to+on? pt1 pt2 z) units))
					(return-from distance_from+to+on? units)
				)
			)
		)
	)
)

;; actual version of walk
(setq walk.actual 
	(make-op.actual :name 'walk.actual :pars '(?x ?y ?z ?f)
	:startconds '((is_at AG ?x)        
				  (is_on ?x ?z)        
				  (is_on ?y ?z) (point y)
				  (navigable ?z)
                  (is_tired_to_degree AG ?f) )
    :stopconds '((not (navigable ?z)) 
    			 (is_at AG ?y) )
    :deletes '((is_at AG ?#1)
    		   (is_tired_to_degree AG ?#2))
    :adds '((is_at AG (the_pt+units_from+towards+on_road? (* 1 (elapsed_time?)) ?x ?y ?z))
    		(is_at AG (the_pt+units_from+towards+on_road? (- (distance_from+to+on? ?x ?y ?z) (* 1 (elapsed_time?))) ?y ?x ?z))
    	    (is_on (the_pt+units_from+towards+on_road? (* 1 (elapsed_time?)) ?x ?y ?z) ?z)
    	    (is_on (the_pt+units_from+towards+on_road? (- (distance_from+to+on? ?x ?y ?z) (* 1 (elapsed_time?))) ?y ?x ?z) ?z)
    		(is_tired_to_degree AG (+ ?f (* 0.5 (elapsed_time?)))) )
    )
)

;;model of drive
(setq drive 
	(make-op :name 'drive :pars '(?x ?y ?z ?f ?c ?m)
	:preconds '((is_at AG ?x)        
				(is_on ?x ?z)        
				(is_on ?y ?z) (point ?y)
				(navigable ?z)
                (is_tired_to_degree AG ?f) 
                (has_car AG ?c)
                (has_gas ?c))
    :effects '((is_at AG ?y) 
    		   (not (is_at AG ?x))
               ;(is_tired_to_degree AG (+ ?f 0.5))
               (is_tired_to_degree AG (+ ?f (* 0.1 (distance_from+to+on? ?x ?y ?z))));less tired than walking
               (not (is_tired_to_degree AG ?f)) 
               (mileage_left (- ?m (distance_from+to+on? ?x ?y ?z))))
    :time-required '(/ (distance_from+to+on? ?x ?y ?z) 10) ;you take 1/10 of the time to drive
    :value '(- 0.5 ?f) ;less fatiguing than walking
    )
)

;;actual drive
(setq drive.actual 
	(make-op.actual :name 'drive.actual :pars '(?x ?y ?z ?f ?c ?m)
	:startconds '((is_at AG ?x)        
				  (is_on ?x ?z)        
				  (is_on ?y ?z) (point y)
				  (navigable ?z)
                  (is_tired_to_degree AG ?f) 
                  (has_car AG ?c)
                  (has_gas ?c)
                 )
    :stopconds '((not (navigable ?z)) 
    			 (is_at AG ?y) )
    :deletes '((is_at AG ?#1)
    		   (is_tired_to_degree AG ?#2))
    :adds '((is_at AG (the_pt+units_from+towards+on_road? (* 0.1 (elapsed_time?)) ?x ?y ?z))
    		(is_at AG (the_pt+units_from+towards+on_road? (- (distance_from+to+on? ?x ?y ?z) (* 1 (elapsed_time?))) ?y ?x ?z))
    	    (is_on (the_pt+units_from+towards+on_road? (* 0.1 (elapsed_time?)) ?x ?y ?z) ?z)
    	    (is_on (the_pt+units_from+towards+on_road? (- (distance_from+to+on? ?x ?y ?z) (* 1 (elapsed_time?))) ?y ?x ?z) ?z)
    		(is_tired_to_degree AG (+ ?f (* 0.1 (elapsed_time?)))) 
    		(mileage_left (- ?m (distance_from+to+on? ?x ?y ?z)))
    		)
    )
)

;;defining gas station
;;gas station is set to have 10000 gallons of gasoline in the beginning
(def-object 'gas_station '(is_location is_inanimate (has_name gridworld_gas) (has_gas 10000)))
(def-object 'gas '(is_inanimate (price_per_gallon 2.5)))
(def-object 'coke '(is_potable (has_cost 1.5)))
(def-object 'hot_dog '(is_edible (has_cost 2)))

(place-object 'gridworld_gas 'gas_station 'gas_station '(gas coke hot_dog) nil nil)

;;defining office
(def-object 'office '(is_location is_inanimate (has_name office gridworld_tower) (has_level 2)))

;;defining supermarket
(def-object 'supermarket '(is_location is_inanimate (has_name supermarket gridworld_market)))
(def-object 'chicken '(is_edible (has_cost 4)))
(def-object 'potato '(is_edible (has_cost 1)))
(def-object 'burger '(is_edible (has_cost 6)))
(def-object 'water '(is_potable (has_cost 1)))

(place-object 'gridworld_supermarket 'supermarket 'supermarket '(chicken potato burger water) nil nil)


;;----------------------------
;;Elana's Code
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
