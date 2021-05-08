;; set up agent
(def-object 'person '(can_talk is_animate))
(def-object 'note '(is_readable))

; load map
(def-roadmap '(home work supermarket gasstation dropoffLoc) 
	'((path1 home 3 supermarket) (path2 home 5 work) (path3 home 4 dropoffLoc)
	  (path4 work 2 supermarket) (path5 work 4 gasstation)
	  (path6 supermarket 2 gasstation) (path7 supermarket 3 dropoffLoc)
	  (path8 dropoffLoc 4 gasstation)))

;;defining gas station
;;gas station is set to have 10000 gallons of gasoline in the beginning
(def-object 'gas_station '(is_location is_inanimate (has_name gridworld_gas) (has_gas 10000)))
(def-object 'gas '(is_inanimate (price_per_gallon 2.5)))
(def-object 'coke '(is_potable (has_cost 1.5)))
(def-object 'hot_dog '(is_edible (has_cost 2)))

(place-object 'gas 'gas1 'gas_station 0 nil nil nil)
(place-object 'coke 'coke1 'gas_station 0 nil nil nil)
(place-object 'hot_dog 'hot_dog1 'gas_station 0 nil nil nil)

(place-object 'gridworld_gas 'gas_station 'gas_station 0 '((gas gas1) (coke coke1) (hot_dog hot_dog1)) nil nil)

;;defining office
(def-object 'office '(is_location is_inanimate (has_name office gridworld_tower) (has_level 2)))

;;defining supermarket
(def-object 'supermarket '(is_location is_inanimate (has_name supermarket gridworld_market)))
(def-object 'chicken '(is_edible (has_cost 4)))
(def-object 'potato '(is_edible (has_cost 1)))
(def-object 'burger '(is_edible (has_cost 6)))
(def-object 'water '(is_potable (has_cost 1)))

(place-object 'chicken1 'chicken 'home 0 nil '((not (is_expired chicken1))) nil)
(place-object 'chicken2 'chicken 'home 0 nil '((is_expired chicken2)) nil)
(place-object 'water1 'water 'home 0 nil nil nil)
;(place-object 'gridworld_supermarket 'supermarket 'supermarket 0 '((chicken chicken1)) nil nil)

;; agent
(place-object 'AG 'person 'home 0
	'((chicken chicken1) (chicken chicken2))
	'(
	(is_tired_to_degree AG 0)
	(is_hungry_to_degree AG 5) ;set it to be hungry
	(is_thirsty_to_degree AG 2)
	(has_money AG 100)
	(has_age AG 25)
	(has_name AG Alex)
	(has_job AG employee)
	(works_at AG office)
	(is_single AG)
	  (is_at AG home)
	  ;other knowledge
	  (not(there_is_a_fire))
	  (not(is_holding_something AG))
	  (not(is_holding AG *))
	  (not (there_is_a_flood))
	  (is_thirsty_to degree AG 0)
	  (has_car AG car1)
	  (has_gaslevel AG car1 100.0)
	  (has_speed AG car1 0)
	  (has_mileagelevel AG car1 250)
	  (knows AG (whether (is_edible chicken1)))
	  (knows AG (whether (is_potable water1)))
	;(has_name Boss Carol) (has_job Boss employer) (works_at Boss office)
	)
	nil
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
				 (not (is_expired ?x))
				 (knows AG (whether (is_expired ?x)))
				 (knows AG (whether (is_edible ?x)))
				 (has AG ?x)
			    )
	:effects '( (is_hungry_to_degree AG 0.0) 
				(not (is_hungry_to_degree AG ?h)) 
				(not (has AG ?x))
				(not (is_at ?x ?y)))
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
				   (has AG ?x)
				   (knows AG (whether (is_edible ?x))) )
	:stopconds '( (there_is_a_fire)
				  (there_is_a_flood) 
				  (is_hungry_to_degree AG 0.0) )
	:deletes '( (is_hungry_to_degree AG ?#1) 
			    (has AG ?x) (is_at ?x ?y))
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
				)
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
	:stopconds '( 
				  		(is_thirsty_to_degree AG 0.0))
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

(setq smell 
	  (make-op 
		:name 'smell
		:pars '(?item)
		:preconds '((has AG ?item) (is_edible ?item))
		:effects '((knows AG (whether (is_expired ?item))))
		:time-required '1
		:value 1 
	  )
)

(setq smell.actual
	  (make-op.actual
		:name 'smell.actual
		:pars '(?item)
		:startconds '((has AG ?item) (is_edible ?item))
		:stopconds '((knows AG (whether (is_expired ?item))))
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
		:effects '((knows AG (message_of? ?item)))
		:time-required 3
		:value 3
	  )
)


(setq read.actual
	  (make-op.actual
		:name 'read.actual
		:pars '(?item ?location)
		:startconds '((is_at AG ?location) (is_at ?item ?location) (is_readable ?item))
		:stopconds '((there_is_a_fire) (knows AG (message_of? ?item)))
		:deletes nil
		:adds '((knows AG (message_of? ?item)))
	  )
)

;Example of a readable item
(place-object 'note1 'note 'home 0 nil '((has_message_that note1 (is_single Carol))) nil)

(defun answer_to_ynq? (wff)
	(check-yn-fact-in-kb 'NIL wff (state-node-wff-htable *curr-state-node*))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function answer_to_ynq.actual? returns a well-formed formula indicating  
;; whether the arg wff is currently in AG's KB, under the closed world 
;; assumption. In addition, the answer is translated into a proper English 
;; sentence and printed on screen.  For example, if AG is currently hungry 
;; according to AG's KB, then (is_hungry AG) is returned as the response to 
;; (answer_to_ynq.actual? '(is_hungry AG)), and ``AG is hungry'' without the 
;; double quotes is printed.  Otherwise, (not (is_hungry AG)) is 
;; returned and ``it is not the case that AG is hungry'' is printed without 
;; the double quotes.
;; This is the `actual' version.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun answer_to_ynq.actual? (wff)
	(check-yn-fact-in-kb 'T wff (state-node-wff-htable *curr-state-node*))
)


(defun answer_to_whq? (wff)
	(check-whq-answer-in-kb 'NIL wff (state-node-wff-htable *curr-state-node*))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function answer_to_whq.actual? returns a collection of well-formed 
;; formula(s) as the answer to the arg wff reflecting what are currently in 
;; AG's KB, under the closed world assumption. Arg wff is a wh-question 
;; with variables prefixed with ? appearing in slots filled by wh-words.  
;; For example, if AG likes only APPLE1 and BANANA2 according to AG's KB,
;; ((likes AG APPLE1) (likes AG BANANA2)) is returned as the response to 
;; (answer_to_whq.actual? '(likes AG ?wh)), and ``AG likes APPLE1'' and ``AG likes 
;; BANANA2'' without double quotes are printed on two lines.  If no answer 
;; is found, '(not (knows (AG the-answer))) is returned and ``it is not the 
;; case that AG knows the answer'' without the double quotes is printed .
;; This is the `actual' version.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun answer_to_whq.actual? (wff)
	(check-whq-answer-in-kb 'T wff (state-node-wff-htable *curr-state-node*))
)
(setq answer_user_ynq 
      (make-op :name 'answer_user_ynq :pars '(?q)
        :preconds '( (wants USER (that (tells AG USER (whether ?q)))) )
        :effects '( (not (wants USER (that (tells AG USER (whether ?q)))))
                    (knows USER (that (answer_to_ynq? ?q)))
			  		)
        :time-required 1
        :value 10
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; With operator answer_user_ynq.actual, AG answers the yes-no question 
;; ?q asked by USER.
;; This is the `actual' version.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq answer_user_ynq.actual 
	(make-op.actual :name 'answer_user_ynq.actual :pars '(?q)
	:startconds '( (wants USER (that (tells AG USER (whether ?q)))) )
	:stopconds '( (not (wants USER (that (tells AG USER (whether ?q))))) )
	:deletes '( (wants USER (that (tells AG USER (whether ?q)))) )
	:adds '( ;(knows USER (that (answer_to_ynq?.actual ?q)))				
					 (says+to+at_time AG (that (answer_to_ynq.actual? ?q)) USER (current_time?))
					 (not (wants USER (that (tells AG USER (whether ?q)))))
		   	 )
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; With operator answer_user_whq, AG answers the wh-question ?q asked by 

(setq answer_user_whq 
	(make-op :name 'answer_user_whq :pars '(?q)
	:preconds '( (wants USER (that (tells AG USER (answer_to_whq ?q)))) )
	:effects '( (not (wants USER (that (tells AG USER (answer_to_whq ?q)))))
				(knows USER (that (answer_to_whq? ?q)))
			  )
	:time-required 1
	:value 10
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; With operator answer_user_whq.actual, AG answers the wh-question ?q 
;; asked by USER.
;; This is the `actual' version.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq answer_user_whq.actual 
	(make-op.actual :name 'answer_user_whq.actual :pars '(?q)
	:startconds '( (wants USER (that (tells AG USER (answer_to_whq ?q)))) )
	:stopconds '( (not (wants USER (that (tells AG USER (answer_to_whq ?q))))) )
	:deletes '( (wants USER (that (tells AG USER (answer_to_whq ?q)))) )
	:adds	'( ;(knows USER (that (answer_to_whq.actual? ?q)))				
			   (says+to+at_time AG (that (answer_to_whq.actual? ?q)) USER (current_time?))
			   (not (wants USER (that (tells AG USER (answer_to_whq ?q)))))
			 )
	)	
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; With operator walk, AG walks from point ?x to point ?y on road ?z, with 
;setup:
(setq *operators* '(eat drink walk smell read answer_user_ynq answer_user_whq))

(setq *search-beam* (list (cons 2 *operators*) (cons 2 *operators*) (cons 2 *operators*)))

