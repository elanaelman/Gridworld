; Our gridworld.

(def-roadmap '(me-home boss-home office) '((path1 me-home 2 office) (path2 boss-home 3 office)))

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

(setq *operators* '(eat sleep walk run drive pick_up put_down push 
						use give buy read smell ask tell))

(setq *search-beam* (list (cons 1 *operators*)))


