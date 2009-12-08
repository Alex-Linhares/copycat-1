(defflavor group
    (group-category ; E.g., "succgrp" or "predgrp".
     (direction-category nil) ; E.g., "left" or "right".
     left-obj right-obj (middle-obj nil) ; The left, right, and middle (if any)
                                         ; objects in this group.
     left-obj-position right-obj-position ; The string-positions of the left 
                                          ; and right objects in this group.
     object-list ; A list of the objects in this group.
     bond-list ; A list of the bonds in this group.
     bond-category ; The bond category associated with the 
                       ; group-category (e.g., "successor" is associated with
                       ; "succgrp").
     (bond-facet nil) ; The description-type upon which the bonds making up
                         ; this group are based (i.e., letter-category or
                         ; length).
     (bond-descriptions nil) ; Descriptions involving the bonds 
                                 ;  making up the group.  These are separated 
				 ; from other descriptions since they are not 
				 ; always used in the same way.

;---------------------------------------------

(defun make-group (string group-category direction-category 
	           left-obj right-obj object-list bond-list 
		   &aux new-group new-group-letter-category 
			length-description-probability new-bond-facet)
; Returns a new group.
  (setq new-group
       (make-instance 'group 
         :string string
         :left-string-position (send left-obj :left-string-position)
         :right-string-position (send right-obj :right-string-position)
	 :structure-category 'group 
         :group-category group-category 
         :direction-category direction-category
         :left-obj left-obj
	 :right-obj right-obj
	 :middle-obj (loop for obj in object-list 
	                   when (eq (send obj :get-descriptor 
					  plato-string-position-category) 
				    plato-middle) 
	                   return obj)
         :left-obj-position (send left-obj :left-string-position)
         :right-obj-position (send right-obj :right-string-position)
	 :object-list object-list
         :bond-list bond-list
	 :bond-category (send group-category 
			      :get-related-node plato-bond-category)))

  ; Add some descriptions to the new group.
  
  ; Add object-category description and string-position description (if any).
  (if* (send new-group :spans-whole-string?)
   then (send new-group :add-description 
	      (make-description new-group plato-string-position-category 
		                plato-whole)))
  (send new-group :add-description 
	(make-description new-group plato-object-category plato-group))

  (cond ((and (send new-group :leftmost-in-string?) 
	      (not (send new-group :spans-whole-string?)))
         (send new-group :add-description 
	       (make-description new-group plato-string-position-category 
		                 plato-leftmost)))
        ((send new-group :middle-in-string?) 
         (send new-group :add-description 
	       (make-description new-group plato-string-position-category 
		                 plato-middle)))
        ((and (send new-group :rightmost-in-string?) 
              (not (send new-group :spans-whole-string?)))
         (send new-group :add-description 
               (make-description new-group plato-string-position-category 
		                 plato-rightmost))))

  ; If new-group is an samegrp based on letter-category, then give it a
  ; letter-category description.
  (if* (and (eq group-category plato-samegrp) 
	    (or (null bond-list)
	        (eq (send (car bond-list) :bond-facet)
		    plato-letter-category)))
   then (setq new-group-letter-category 
	      (send (send new-group :left-obj) :get-descriptor 
		    plato-letter-category))
        (send new-group :add-description 
	      (make-description new-group plato-letter-category 
		                new-group-letter-category))
	(send new-group :set-pname 
	      (send new-group-letter-category :pname)))

  ; Add group-category, direction-category, and bond descriptions.
  (send new-group :add-description 
	(make-description new-group plato-group-category group-category))
  (if* (send new-group :direction-category)
   then (send new-group :add-description 
	      (make-description new-group plato-direction-category 
 		                (send new-group :direction-category))))
  
  ; Add some descriptions of the bonds making up the group to the 
  ; group's bond-descriptions.
  ; The bond-facet is either letter-category or length.
  ; This assumes that all bonds in the group are based on the same facet.
  (if* (send new-group :bond-list)
   then (setq new-bond-facet 
	      (send (car (send new-group :bond-list)) :bond-facet))
        (send new-group :set-bond-facet new-bond-facet)
        (send new-group :add-bond-description 
	      (make-description new-group plato-bond-facet 
		                new-bond-facet)))
 
  (send new-group :add-bond-description 
	(make-description new-group plato-bond-category
	                  (send new-group :bond-category)))
 
  ; Decide whether or not to add a length description to the group.
  ; Only length descriptions from 1 to 5 can be added to groups.  This
  ; is not very general and should eventually be fixed.
  (setq length-description-probability 
        (send new-group :length-description-probability))

  (if* (eq (flip-coin length-description-probability) 'heads)
   then  
        (send new-group :add-description
	      (make-description new-group plato-length
		                (get-plato-number (send new-group :length))))
  new-group)

;----------------------------------------------
; group.print | REMOVED
;---------------------------------------------

;---------------------------------------------
; group.add-bond-description | Group.add_bond_description
;---------------------------------------------

;---------------------------------------------
; group.length | Group.length
;---------------------------------------------

;---------------------------------------------
; group.leftmost-letter | Group.leftmost_letter
; group.rightmost-letter | Group.rightmost_letter
;---------------------------------------------

(defmethod (group :leftmost-in-string?) ()
; Returns t if the group is leftmost in its string.
  (if* (= left-obj-position 0) then t else nil))

;---------------------------------------------

(defmethod (group :rightmost-in-string?) ()
; Returns t if the group is rightmost in its string.
  (if* (= right-obj-position (1- (send string :length))) 
   then t else nil))

;---------------------------------------------

(defmethod (group :left-neighbor) (&aux possible-left-neighbor)
  (if* (send self :leftmost-in-string?) 
   then nil
   else (setq possible-left-neighbor
	      (send (send string :get-letter (1- left-obj-position)) 
		    :group))
        (if* (null possible-left-neighbor) 
	 then nil
	 else ; If this group is grouped with the object to the 
	      ; left, or if this group is a subgroup of the group to the left,
              ; don't count the larger group as the left-neighbor.
              (if* (and (not (memq self (send possible-left-neighbor 
					      :object-list)))
			(not (subgroup? self possible-left-neighbor)))
               then possible-left-neighbor else nil))))

;---------------------------------------------

(defmethod (group :right-neighbor) (&aux possible-right-neighbor)
  (if* (send self :rightmost-in-string?) 
   then nil
   else (setq possible-right-neighbor
	      (send (send string :get-letter (1+ right-obj-position)) 
		    :group))
        (if* (null possible-right-neighbor)
         then nil
	 else ; If this group is grouped with the object to the 
              ; right, or if this group is a subgroup of the group to the 
	      ; right, don't count the larger group as the right-neighbor.
              (if* (and (not (memq self (send possible-right-neighbor 
					      :object-list)))
			(not (subgroup? self possible-right-neighbor)))
               then possible-right-neighbor else nil))))

;---------------------------------------------
; build-group | Workspace.build_group
;---------------------------------------------

;---------------------------------------------
; break-group | Workspace.break_group
;---------------------------------------------

(defun top-down-group-scout--category 
      (group-category  
       &aux string bond-category chosen-object chosen-bond 
            direction-category bond-facet
            opposite-bond-category opposite-direction-category
            direction-to-scan num-of-bonds-to-scan quit
  	    next-bond next-object bond-to-add object-list bond-list
	    i-relevance t-relevance i-unhappiness t-unhappiness
	    possible-single-letter-group 
	    possible-single-letter-group-direction
	    single-letter-group-probability)
			      
; This codelet looks for evidence of a group of the given type.
; Chooses an object, a direction to scan in, and a number of bonds to 
; scan in that direction.  The direction-category of the group is the direction
; of the first bond scanned.  If there are no bonds and the group 
; category is not plato-samegrp, then chooses a direction-category 
; probabilistically as a function of global and local relevance.  Scans until 
; no more bonds of the necessary type and direction are found.  If 
; possible, makes a proposed group of the given type out of the objects 
; scanned, and posts a group-strength-tester codelet with urgency a function 
; of the degree-of-association of bonds of the given bond-category.

(block nil

  (if* %verbose% 
   then (format t "In top-down-group-scout--category with group type ~a~&" 
	        (send group-category :pname)))

  (setq bond-category 
	(send group-category :get-related-node plato-bond-category))

  ; Choose string probabilistically as a function of 
  ; local-bond-category-relevance.
  (setq i-relevance (send *initial-string* :local-bond-category-relevance 
			bond-category))
  (setq t-relevance (send *target-string* :local-bond-category-relevance 
			bond-category))

  (setq i-unhappiness (send *initial-string* :intra-string-unhappiness))
  (setq t-unhappiness (send *target-string* :intra-string-unhappiness))

  (if* %verbose% 
   then (format t "About to choose string.  Relevance of ~a is: " 
		(send bond-category :pname))
        (format t "i-relevance: ~a, t-relevance: ~a~&"
	        i-relevance t-relevance)
	(format t "i-unhappiness: ~a, t-unhappiness: ~a~&"
		i-unhappiness t-unhappiness))
                  
  (setq string 
	(nth (select-list-position 
		 (list (round (average i-relevance i-unhappiness))
		       (round (average t-relevance t-unhappiness))))
	     (list *initial-string* *target-string*)))
		
  (if* %verbose% 
   then (format t "Chose ~a~&" (send string :pname)))

  ; Choose an object on the workspace by intra-string-salience.
  (setq chosen-object (send string :choose-object ':intra-string-salience))

  (if* %verbose% 
   then (format t "Chose object ") (send chosen-object :print) (format t "~%"))
  
  ; If the object is a group that spans the string, fizzle.
  (if* (send chosen-object :spans-whole-string?)
   then (if* %verbose% 
	 then (format t "This object spans the whole string.  Fizzling.~&"))
        (return))

  ; Now choose a direction in which to scan. 
  (setq direction-to-scan
	(cond ((send chosen-object :leftmost-in-string?) plato-right)
              ((send chosen-object :rightmost-in-string?) plato-left)
	      (t (select-list-item-by-method (list plato-left plato-right) 
	                                     :activation))))

  ; Now choose a number of bonds to scan.
  (setq num-of-bonds-to-scan 
	(select-list-position 
	    (send string :num-of-bonds-to-scan-distribution)))

  (if* %verbose% 
   then (format t "About to scan ~a bonds to the ~a~&" 
		  num-of-bonds-to-scan (send direction-to-scan :pname)))
  
  ; Now get the first bond in that direction.
  (if* (eq direction-to-scan plato-left)
   then (setq chosen-bond (send chosen-object :left-bond))
   else (setq chosen-bond (send chosen-object :right-bond)))

  (if* (or (null chosen-bond)
	   (not (eq (send chosen-bond :bond-category) 
		     bond-category)))
   then (if* %verbose% 
         then (format t "No ~a bond in this direction.~&"
		      (send bond-category :pname)))
        (if* (typep chosen-object 'group) 
         then (if* %verbose% 
	       then (format t "Can't make group from single group. ")
	            (format t "Fizzling.~&"))
	      (return))
        (setq object-list (list chosen-object))
        (setq bond-list nil)
        ; A single-letter group should be proposed only if the local
	; support is very high.
        (setq possible-single-letter-group-direction
	      (if* (eq group-category plato-samegrp)
               then nil
	       else (nth (select-list-position ; Select left or right depending
			                       ; on local support.
			     (list (send plato-left 
					 :local-descriptor-support 
					 string plato-group)
				   (send plato-right 
					 :local-descriptor-support 
					 string plato-group)))
			 (list plato-left plato-right))))

        (setq possible-single-letter-group 
	      (make-group 
		  string group-category possible-single-letter-group-direction
                  chosen-object chosen-object object-list bond-list))

        ; If length is active and there is lots of support,
	; then a single-letter group has a good chance.  
	; length has a better chance of staying active
	; if bonds have been built between other lengths.
        (setq single-letter-group-probability 
	      (send possible-single-letter-group 
		    :single-letter-group-probability))

	(if* %verbose% 
	 then (format t "Considering single letter group: ")
	      (send possible-single-letter-group :print)
	      (format t "Propose probability: ~a~&"
		        single-letter-group-probability))
	(if* (eq (flip-coin single-letter-group-probability) 'heads)
         then (if* %verbose% 
               then (format t 
			     "About to propose single letter group!~&"))
              (propose-group object-list bond-list group-category 
		             possible-single-letter-group-direction)
	 else (if* %verbose% 
	       then (format t "Local support not strong enough. Fizzling.~&")))
	(return))
     
  (if* %verbose% 
   then (format t "The first bond is: ") 
        (send chosen-bond :print))

  (setq direction-category (send chosen-bond :direction-category))
  (setq bond-facet (send chosen-bond :bond-facet))

  (setq opposite-bond-category 
	(send bond-category :get-related-node plato-opposite))
  (if* direction-category
   then (setq opposite-direction-category 
	      (send direction-category :get-related-node plato-opposite)))

  ; Get a list of the objects and bonds.
  ; This assumes that there is at most one bond between any pair of 
  ; objects.  If there are bonds that are opposite in bond category 
  ; and direction to the chosen bond, then add their flipped versions to 
  ; the bond list.
  (setq object-list (list (send chosen-bond :left-obj)
			  (send chosen-bond :right-obj)))
  (setq bond-list (list chosen-bond))
  (setq next-bond chosen-bond)
  (loop for i from 2 to num-of-bonds-to-scan until quit do
        (setq bond-to-add nil)
        (if* (eq direction-to-scan plato-left)
         then (setq next-bond (send next-bond :choose-left-neighbor))
	      (if* (null next-bond) 
	       then (setq quit t) 
	       else (setq next-object (send next-bond :left-obj)))
         else (setq next-bond (send next-bond :choose-right-neighbor))
	      (if* (null next-bond) 
	       then (setq quit t) 
	       else (setq next-object (send next-bond :right-obj))))
	       
        ; Decide whether or not to add bond.
	(cond ((null next-bond) (setq bond-to-add nil))
	      ((and (eq (send next-bond :bond-category) 
			bond-category)
		    (eq (send next-bond :direction-category) 
			direction-category)
		    (eq (send next-bond :bond-facet) bond-facet))
               (setq bond-to-add next-bond))
	      ((and (eq (send next-bond :bond-category) 
			opposite-bond-category)
		    (eq (send next-bond :direction-category) 
			opposite-direction-category)
		    (eq (send next-bond :bond-facet) bond-facet))
	       (setq bond-to-add (send next-bond :flipped-version))))
	      
        (if* bond-to-add
         then (push next-object object-list)
              (push bond-to-add bond-list)
	 else (setq quit t)))
  
  (propose-group object-list bond-list group-category direction-category)))
  
;---------------------------------------------
 
(defun top-down-group-scout--direction 
      (direction-category  
       &aux string chosen-object chosen-bond group-category
            bond-category bond-facet
            opposite-bond-category opposite-direction-category
            direction-to-scan num-of-bonds-to-scan quit
  	    next-bond next-object bond-to-add object-list bond-list
	    i-relevance t-relevance i-unhappiness t-unhappiness)
			      
; This codelet looks for evidence of a group of the given direction.
; Chooses an object, a direction to scan in, and a number 
; of bonds to scan in that direction.  The group-category of the group
; is the associated group-category of the first bond scanned.  (Note that
; for now, this codelet cannot propose groups of only one object.) 
; Scans until no more bonds of the necessary type and direction are found.
; If possible, makes a proposed group of the given direction out of the 
; objects scanned, and posts a group-strength-tester codelet with urgency a 
; function of the degree-of-association of bonds of the given 
; bond-category.

(block nil

  (if* %verbose% 
   then (format t "In top-down-group-scout--direction with direction ~a~&" 
	        (send direction-category :pname)))

  (setq i-relevance (send *initial-string* :local-direction-category-relevance 
			direction-category))
  (setq t-relevance (send *target-string* :local-direction-category-relevance 
			direction-category))

  (setq i-unhappiness (send *initial-string* :intra-string-unhappiness))
  (setq t-unhappiness (send *target-string* :intra-string-unhappiness))

  (if* %verbose% 
   then (format t "About to choose string.  Relevance of ~a is: " 
		(send direction-category :pname))
        (format t "initial string: ~a, target string: ~a~&"
		  i-relevance t-relevance)
	(format t "i-unhappiness: ~a, t-unhappiness: ~a~&"
		  i-unhappiness t-unhappiness))

  (setq string 
	(nth (select-list-position 
		 (list (round (average i-relevance i-unhappiness))
		       (round (average t-relevance t-unhappiness))))
	     (list *initial-string* *target-string*)))
		
  (if* %verbose% then (format t "Chose ~a~&" (send string :pname)))

  ; Choose an object on the workspace by intra-string-salience.
  (setq chosen-object (send string :choose-object ':intra-string-salience))

  (if* %verbose% 
   then (format t "Chose object ") (send chosen-object :print) (format t "~%"))
  
  ; If the object is a group that spans the string, fizzle.
  (if* (send chosen-object :spans-whole-string?)
   then (if* %verbose% 
	 then (format t "This object spans the whole string.  Fizzling.~&"))
        (return))

  ; Now choose a direction in which to scan. 
  (setq direction-to-scan
	(cond ((send chosen-object :leftmost-in-string?) plato-right)
              ((send chosen-object :rightmost-in-string?) plato-left)
	      (t (select-list-item-by-method (list plato-left plato-right) 
	                                     :activation))))

  ; Now choose a number of bonds to scan.
  (setq num-of-bonds-to-scan 
	(select-list-position 
	    (send string :num-of-bonds-to-scan-distribution)))

  (if* %verbose% 
   then (format t "About to scan ~a bonds to the ~a~&" 
		  num-of-bonds-to-scan (send direction-to-scan :pname)))
  
  ; Now get the first bond in that direction.
  (if* (eq direction-to-scan plato-left)
   then (setq chosen-bond (send chosen-object :left-bond))
   else (setq chosen-bond (send chosen-object :right-bond)))

  (if* (null chosen-bond)
   then (if* %verbose% then (format t "No bond in this direction.~&"))
	(return))
     
  (if* %verbose% 
   then (format t "The first bond is: ") 
        (send chosen-bond :print))

  (if* (not (eq (send chosen-bond :direction-category) direction-category))
   then (if* %verbose% 
	 then (format t "Chosen bond has wrong direction.  Fizzling.~&"))
        (return))

  (setq bond-category (send chosen-bond :bond-category))
  (setq bond-facet (send chosen-bond :bond-facet)) 

  (setq opposite-bond-category 
	(send bond-category :get-related-node plato-opposite))
  (setq opposite-direction-category 
	(send direction-category :get-related-node plato-opposite))

  ; Get a list of the objects and bonds.
  ; This assumes that there is at most one bond between any pair of 
  ; objects.  If there are bonds that are opposite in bond category 
  ; and direction to the chosen bond, then add their flipped versions to 
  ; the bond list.
  (setq object-list (list (send chosen-bond :left-obj)
			  (send chosen-bond :right-obj)))
  (setq bond-list (list chosen-bond))
  (setq next-bond chosen-bond)
  (loop for i from 2 to num-of-bonds-to-scan until quit do
        (setq bond-to-add nil)
        (if* (eq direction-to-scan plato-left)
         then (setq next-bond (send next-bond :choose-left-neighbor))
	      (if* (null next-bond) 
	       then (setq quit t) 
	       else (setq next-object (send next-bond :left-obj)))
         else (setq next-bond (send next-bond :choose-right-neighbor))
	      (if* (null next-bond) 
	       then (setq quit t) 
	       else (setq next-object (send next-bond :right-obj))))
	       
        ; Decide whether or not to add bond.
	(cond ((null next-bond) (setq bond-to-add nil))
	      ((and (eq (send next-bond :bond-category) 
			bond-category)
		    (eq (send next-bond :direction-category) 
			direction-category)
		    (eq (send next-bond :bond-facet) bond-facet))
               (setq bond-to-add next-bond))
	      ((and (eq (send next-bond :bond-category) 
			opposite-bond-category)
		    (eq (send next-bond :direction-category) 
			opposite-direction-category)
		    (eq (send next-bond :bond-facet) bond-facet))
	       (setq bond-to-add (send next-bond :flipped-version))))
	      
        (if* bond-to-add
         then (push next-object object-list)
              (push bond-to-add bond-list)
	 else (setq quit t)))
  
  (setq group-category 
	(send bond-category :get-related-node plato-group-category))

  (propose-group object-list bond-list group-category direction-category)))

;---------------------------------------------
; group-scout--whole-string | GroupWholeStringScout
;---------------------------------------------

;---------------------------------------------
; group-strength-tester | GroupStrengthTester
;---------------------------------------------

;---------------------------------------------
; group-builder | GroupBuilder
;---------------------------------------------

(defmethod (group :flipped-version) (&aux new-bond-list flipped-group)
; Returns the flipped version of this group (e.g., if the group is
; a successor group going to the right, returns a predecessor group going to
; the left, using the same objects).
  (if* (not (or (eq group-category plato-predgrp) 
		(eq group-category plato-succgrp)))
   then self
   else (setq new-bond-list 
	      (loop for r in bond-list collect (send r :flipped-version)))

        (setq flipped-group
              (make-group 
		  string 
		  (send group-category :get-related-node plato-opposite) 
		  (send direction-category :get-related-node plato-opposite) 
		  left-obj right-obj object-list new-bond-list))
        (send flipped-group :set-proposal-level (send self :proposal-level))
        flipped-group))
               
;---------------------------------------------
; get-possible-group-bonds | Workspace.possible_group_bonds
;---------------------------------------------

(defun group-equal? (group1 group2)   
; Returns t if the two groups are the same.
  (if* (and group1 group2
           (= (send group1 :left-obj-position) 
	      (send group2 :left-obj-position))
           (= (send group1 :right-obj-position) 
	      (send group2 :right-obj-position))
           (eq (send group1 :group-category) 
	       (send group2 :group-category))
           (eq (send group1 :direction-category) 
	       (send group2 :direction-category)))
   then t else nil))
   
;---------------------------------------------

(defun in-group? (obj1 obj2)
; Returns t if the two objects are in a group.
 (and (send obj1 :group) (eq (send obj1 :group) (send obj2 :group))))

;---------------------------------------------

(defun subgroup? (group1 group2)
; Returns t if group1 is a subgroup of group2.  Otherwise, returns nil.
  (and (<= (send group2 :left-obj-position) 
	   (send group1 :left-obj-position))
       (>= (send group2 :right-obj-position) 
	   (send group1 :right-obj-position))))

;---------------------------------------------

(defun groups-overlap? (group1 group2)
; Returns t if the two groups overlap.  Otherwise returns nil.
  (intersection (send group1 :object-list) (send group2 :object-list)))

;---------------------------------------------

(defmethod (group :get-incompatible-groups) ()
; Returns a list of the groups that are incompatible with the given group.
  (remove self (remove-duplicates 
		   (flatten (send-method-to-list object-list :group)))))

;---------------------------------------------

(defmethod (group :get-incompatible-correspondences) ()
; Returns a list of the correspondences that are incompatible with the given 
; group.
  (loop for obj in object-list
        when (and (send obj :correspondence) 
	  	  (send self :incompatible-correspondence? 
			     (send obj :correspondence) obj))
        collect (send obj :correspondence)))

;---------------------------------------------

(defmethod (group :incompatible-correspondence?) 
           (c obj &aux string-position-category-concept-mapping other-obj
		    other-bond group-concept-mapping)
; Returns t if the given correspondence is incompatible with the given group.
(block nil
  (setq string-position-category-concept-mapping
        (loop for cm in (send c :concept-mapping-list)
              when (eq (send cm :description-type1) plato-string-position-category)
	      return cm))

  (if* (null string-position-category-concept-mapping)
   then (return nil))
  (setq other-obj (send c :other-obj obj))
  (if* (send other-obj :leftmost-in-string?)
   then (setq other-bond (send other-obj :right-bond))
   else (if* (send other-obj :rightmost-in-string?)
	 then (setq other-bond (send other-obj :left-bond))))
  (if* (or (null other-bond) 
	   (null (send other-bond :direction-category))) 
   then (return nil))
  (setq group-concept-mapping
        (make-concept-mapping 
	    plato-direction-category plato-direction-category
 	    direction-category (send other-bond :direction-category)
	    nil nil))
  (if* (incompatible-concept-mappings? 
	   group-concept-mapping string-position-category-concept-mapping)
   then t)))

;---------------------------------------------
; group.get-bonds-to-be-flipped | Group.get_bonds_to_be_flipped
;---------------------------------------------

(defmethod (group :spans-whole-string?) ()
; Returns t if the group spans the string.
  (= (send self :letter-span) (send string :length)))

;---------------------------------------------

(defmethod (group :proposed?) ()
  (< proposal-level %built%))

;---------------------------------------------
; propose-group | Workspace.propose_group
;---------------------------------------------
  
(defmethod (group :single-letter-group-probability) (&aux exponent)
; Returns the probability to be used in deciding whether or not to propose the
; single-letter-group g.  
  (setq exponent (case (send self :number-of-local-supporting-groups)
		       (1 4)
		       (2 2)
		       (otherwise 1)))
	
  (get-temperature-adjusted-probability
      (expt (* (/ (send self :local-support) 100)
	       (/ (send plato-length :activation) 100)) exponent)))

;-------------------------------------------

(defmethod (group :length-description-probability) ()
  (if* (> (send self :length) 5)
   then 0
   else (get-temperature-adjusted-probability 
	    (expt .5 (* (cube (send self :length))
			(/ (fake-reciprocal (send plato-length 
						  :activation)) 100))))))


