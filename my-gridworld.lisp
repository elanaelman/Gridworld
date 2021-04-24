; Our gridworld.

;;; construct the map
(def-roadmap '(me-home boss-home office) '((path1 me-home 2 office) (path2 boss-home 3 office)))
;;little triangle loop on the bottom of the map
(def-roadmap '(gas_station supermarket office) '(loop1 office 2 supermarket 1 gas_station 2 office))

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