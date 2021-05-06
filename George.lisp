;; set up agent
(def-object 'person '(can_talk is_animate))
(def-object 'note '(is_readable))

; load map
(def-roadmap '(home work supermarket gasstation dropoffLoc) 
	'((path1 home 3 supermarket) (path2 home 5 work) (path3 home 4 dropoffLoc)
	  (path4 work 2 supermarket) (path5 work 4 gasstation)
	  (path6 supermarket 2 gasstation) (path7 supermarket 3 dropoffLoc)
	  (path8 dropoffLoc 4 gasstation)))

(place-object 'AG 'person 'me-home 0  
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

(place-object 'gridworld_gas 'gas_station 'gas_station 0 '('gas 'coke 'hot_dog) nil nil)

;;defining office
(def-object 'office '(is_location is_inanimate (has_name office gridworld_tower) (has_level 2)))

;;defining supermarket
(def-object 'supermarket '(is_location is_inanimate (has_name supermarket gridworld_market)))
(def-object 'chicken '(is_edible (has_cost 4)))
(def-object 'potato '(is_edible (has_cost 1)))
(def-object 'burger '(is_edible (has_cost 6)))
(def-object 'water '(is_potable (has_cost 1)))

(place-object 'gridworld_supermarket 'supermarket 'supermarket 0 '('chicken 'potato 'burger 'water) nil nil)

;setup:
(setq *operators* '(eat drink walk))

(setq *search-beam* (list (cons 1 *operators*)))
