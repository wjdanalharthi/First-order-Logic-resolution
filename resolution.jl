
function substitue(c, unifiable)
   	first = copyClause(c)
   	for (key, val) in unifiable
      		for w = 1:length(first)
         			for j = 1:length(first[w].args)
            				if first[w].args[j].op == key.op
               					first[w].args[j] = val
            				end
         			end
      		end
   	end
   	return first
end

function resolveHelper(kb, query)
	# add negated clause to kb
   	dict = index_clauses(kb)

	# for any two clauses 
	# if we can unify, do it and reduce
  	 unifiable = []
  	 for k = 1:length(kb.clauses)                        # [Howl(x), ~Hound(x)]
     		 for m = 1:length(kb.clauses[k][2])                 # Howl(x)

        			 clauses_indices = []
        			 if kb.clauses[k][2][m].negated
           				 clauses_indices = dict[kb.clauses[k][2][m].op]   # clauses with ~Howl(x)
        			 else
           				 clauses_indices = dict["~" * kb.clauses[k][2][m].op]
         			end

        			 for i in clauses_indices          # index of ~Has(w,t), ~Howl(t), ~LS(w)
				 
           				 rel_index = findall(x->x.op == kb.clauses[k][2][m].op, kb.clauses[i][2])[1]
				
           				 unifiable, flip = MGU(kb.clauses[k][2], m, kb.clauses[i][2], rel_index)
            				if length(unifiable) == 0 
               					println("\n Not Unifiable")
               					continue
            				end 

            				substituted = nothing
            				if flip
               					substituted = (kb.clauses[i][1], substitue(copyClause(kb.clauses[i][2]), unifiable))
            				else
               					substituted = (kb.clauses[k][1], substitue(copyClause(kb.clauses[k][2]), unifiable))
            				end

            				union = nothing
            				if flip
               					union = append!(copyClause(substituted[2]), copyClause(kb.clauses[k][2]))
            				else
               					union = append!(copyClause(substituted[2]), copyClause(kb.clauses[i][2]))
            				end
				
            				indices = nothing
            				if flip
               					indices = findall(x->x.op == substituted[2][rel_index].op && allEqual(x.args, substituted[2][rel_index].args), union)
            				else
               					indices = findall(x->x.op == substituted[2][m].op && allEqual(x.args, substituted[2][m].args), union)
            				end
					
            				deleteat!(union, indices)
				
            				if length(union) == 0
                    				printResolution("$(kb.clauses[i][1]),$(kb.clauses[k][1])",
                                                                "$(printUnifiers(unifiable))",
                                                                "$(length(kb.clauses))",
                                                                union, false)
               					return true
            				else
               					flag = tell(kb, union)
               					if flag
                  					printResolution("$(kb.clauses[i][1]),$(kb.clauses[k][1])",
								"$(printUnifiers(unifiable))",
								"$(length(kb.clauses))",
								union)
                  						return false
               					end
            				end
         			end
      		end
   	end
   	return false
end

function resolve(kb, query)
   	tell_cnf_terms(kb, [skolemize(negate(toCNF(query)))])
	println("\nKB ∪ ~Query")
	println(kb)
	
	println("$(repeat("-", 45))")
	println("Rule # |           θ $(repeat(" ", 10))|   New Rule")
   	println("$(repeat("-", 45))")
   	while true
      		flag = resolveHelper(kb, query)
      		if flag
         		printEnd("Reached an empty clause\nKB entails query")
  	       		return true
      		else
          		sort!(kb.clauses, by = x->length(x[2]))
      		end
   	end
   	printEnd("Couldn't prove KB entails query. \nDoes Not entail")
   	return false
end
