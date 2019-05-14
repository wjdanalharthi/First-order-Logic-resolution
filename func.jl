using Printf

function negate(c::Clause)
	return negateHelper(Clause("~", [c]))
end

function negateHelper(c::Clause)
	if c.op == "~"
		arg = c.args[1]
		if typeof(arg) == Quantifier
			return negate(arg)
		elseif arg.op == "~"
			return negateHelper(arg.args[1])
		elseif arg.op == "&"
			return associate("|", map(negate, arg.args))
		elseif arg.op == "|"
			return associate("&", map(negate, arg.args))
		else
			return c
		end
	elseif (is_symbol(c.op) || (length(c.args) == 0))
		return c
	else
		return Clause(c.op, map(negateHelper, c.args))

	end
end

function negateHelper(q::Quantifier)
	return negate(q)
end

function negate(q::Quantifier)
	new_q = Quantifier(q.op, q.var)

	if q.op == forallTok
		new_q.op = existsTok
	elseif q.op == existsTok
		new_q.op = forallTok
	else
		error("negateHelper(): Unknown quantifier operator $(q.op)")
	end
	new_q.args = negateHelper(Clause("~", [q.args]))
	return new_q
end

function associate(op::String, args::Array)
	dis_args = dissociate(op, args)
	operator = op
	if length(dis_args) == 0
	        if (operator == "&")
        	    return Clause("TRUE");
        	elseif (operator == "|")
            	    return Clause("FALSE");
	        elseif (operator == "+")
        	    return Clause("0");
	        elseif (operator == "*")
        	    return Clause("1");
	    	else
			Base.error("DO NOT KNOW OP")
		end
	elseif (length(dis_args) == 1)
		return dis_args[1]
	else
		return Clause(op, dis_args)
	end
end

function dissociate(operator::String, arguments::Array)
    local result = Array{Any, 1}([]);
    dissociate_collect(operator, arguments, result);
    return result;
end

function dissociate_collect(operator::String, arguments::Array, result_array::AbstractVector)
    for argument in arguments
        if (argument.op == operator)
            dissociate_collect(operator, argument.args, result_array);
        else
            push!(result_array, argument);
        end
    end
    nothing;
end

function eliminate_implications(q::Quantifier)
	return Quantifier(q.op, q.var, eliminate_implications(q.args))
end

function eliminate_implications(e::Clause)
    if ((length(e.args) == 0) || is_symbol(e.op))
        return e;
    end
    local arguments = map(eliminate_implications, e.args);
    local a = first(arguments);
    local b = last(arguments);
    if (e.op == "==>")
	    return Clause("|", [b, Clause("~", [a])]);
    elseif (e.op == "<==")
	    return Clause("|", [a, Clause("~", [b])]);
    elseif (e.op == "<=>")
	    return Clause("&", [Clause("|", [a, Clause("~", [b])]), Clause("|", [b, Clause("~", [a])])]);
    else
        if (!(e.op in ("&", "|", "~")))
            Base.error("EliminateImplicationsError: Found an unexpected operator '", e.op, "'!");
        end
	return Clause(e.op, arguments);
    end
end

function is_symbol(s::String)
        if length(s) == 0
                return false
        else
                return Base.isletter(s[1])
        end
end

function is_variable(v::String)
        return is_symbol(v) && Base.islowercase(v[1])
end

function is_variable(c::Clause)
	return length(c.args) == 0 && Base.islowercase(c.op)
end

function constant(c::String)
	return length(c.args) == 0 && Base.isupper(c.op[1])
end

#function toCNF(a::Array{Clause, 1})

#end

function toCNF(c::Clause)
	c = eliminate_implications(c)
	c = negateHelper(c)
	return distribute_and_over_or(c)
end

function toCNF(q::Quantifier)
	q.args = toCNF(q.args)
	return q
end

function distribute_and_over_or(e::Clause)
    if (e.op == "|")
        local a::Clause = associate("|", e.args);
        if (a.op != "|")
            return distribute_and_over_or(a);
        elseif (length(a.args) == 0)
            return Clause("FALSE");
        elseif (length(a.args) == 1)
            return distribute_and_over_or(a.args[1]);
        end
        conjunction = findfirst((function(arg)
                            return (arg.op == "&");
                        end), a.args);
        if (conjunction === nothing)  #(&) operator was not found in a.arguments
            return a;
        else
            conjunction = a.args[conjunction];
        end
	others = collect(a for a in a.args if (!(a == conjunction)));
        rest = associate("|", others);
	return associate("&", collect(distribute_and_over_or(Clause("|", [conjunction_arg, rest]))
					for conjunction_arg in conjunction.args));
    elseif (e.op == "&")
        return associate("&", map(distribute_and_over_or, e.args));
    else
        return e;
    end
end

function is_variable(c::Clause)
	return !(c.op in OPS) && length(c.args) == 0 && Base.islowercase(c.op[1])
end

function is_constant(c::Clause)
        return !(c.op in OPS) && length(c.args) == 0 && Base.isuppercase(c.op[1])
end

function is_relation(c::Clause)
        return !(c.op in OPS) && length(c.args) != 0 && Base.isuppercase(c.op[1])
end

function is_function(c::Clause)
	return !(c.op in OPS) && length(c.args) != 0 && Base.islowercase(c.op[1])
end

# TODO COMPLETE
function occurs(var::String, args::Array)
	# check if the subt val in c1 vars
	
	for arg in args
		if arg.op == var return true end
	end
	return false
end

function MGU(c1::Clause, c2::Clause)
	return MGU([c1], 1, [c2], 1)
end

function MGU(c1::Array, k, c2::Array, m)
	dict = Dict()
	flip = false
	for i=1:length(c1[k].args)
		result = MGUHelper(c1[k].args[i], c2[m].args[i])
		flip = false
		if length(result) == 2
			occurs_check, subt = result
		else
			occurs_check, subt, flip = result
		end
		if subt != false
			if length(subt) != 0
				dict[subt[1]] = copyClause(subt[2])
			end
		else
			return ()
		end
	end
	return dict, flip 
end

function MGUHelper(c1::Clause, c2::Clause)
	#println("$(c1.op), $(c2.op)")
        if is_constant(c1) && is_constant(c2)
        	#println("cons & cons")
		#TODO what does success mean??
		if c1.op == c2.op return false, (c1,c2)
                else return false, false end
        end
        if is_constant(c1) && is_variable(c2)
		#println("cons & var")
		# TODO flip clauses!
		return false, (c2,c1), true
        end
        if is_constant(c1) && is_function(c2)
		#println("cons & rel")
                return false, false
        end

        if is_variable(c1) && is_constant(c2)
		#println("var & cons")
		return false, (c1,c2)
        end
        if is_variable(c1) && is_variable(c2)
		#println("var & var")
		#if c1.op == c2.op
		#	return false, false
		#end
                return false, (c1,c2)
        end
        if is_variable(c1) && is_function(c2)
		#println("var & rel")
                # TODO occurance checker
		if occurs(c1.op, c2.args)
			return false, false
		end
		return true, (c1,c2)
        end

        if is_function(c1) && is_constant(c2)
		#println("rel & cons")
                return false, false
        end
        if is_function(c1) && is_variable(c2)
		#println("rel & var")
                # TODO occurance checker
		# TODO flip clauses!
		if occurs(c2.op, c1.args)
			return false, false
		end
                return true, (c2,c1), true
        end
        if is_function(c1) && is_function(c2)
		#println("rel & rel")
                if c1.op != c1.op return false end
                return MGU(c1.args, c2.args) #TODO Fix
        end
end

function Base.show(io::IO, d::Dict)
	s = "{"
	for (k, v) in d
		s*="$k=>$v, "
	end
	s=s[1:end-2]
	s*="}"
	print(s)
end

function substitue(c, unifiable)
	first = copyClause(c)
	for (key, val) in unifiable
		for w=1:length(first)
			for j=1:length(first[w].args)
				if first[w].args[j].op == key.op
					first[w].args[j] = val
				end
			end
		end
	end
	return first
end

function printUnifiers(d::Dict)
	s = "{"
	for (k,v) in d
		s*=printClause(k)
		s*="->"
		s*=printClause(v)
		s*=", "
	end
	s=s[1:end-2]
	s*="}"
	return s
end


function printClause(t::Any, indent::String="")
        s = ""
	if !(t.op in OPS)
                if length(t.args) == 0
                        s*="$(t.op)"
                else
                if t.negated
                        s*="~"
                end
                curr = "$(t.op)("
                for i=1:length(t.args)
                        curr*="$(t.args[i].op)"
                        if length(t.args[i].args) != 0
                                curr*= "("
                                for a=1:length(t.args[i].args)
                                        curr*="$(t.args[i].args[a].op),"
                                end
                                curr = curr[1:end-1]
                                curr*="), "
                        else
                                curr*=", "
                        end
                end
                curr=curr[1:end-2]
                curr*=")"
                s*=curr
		end
        else
                if t.op == "~"
                        s*="$(t.op)"
                        for i=1:length(t.args)
                                s*=printClause(t.args[i], indent*"\t")
                        end
                else
                        s*=printClause(t.args[1], indent*"\t")
                        s*=" $(t.op) "
                        for i=2:length(t.args)-1
                                s*=printClause(t.args[i], indent*"\t")
                                s*=" $(t.op) "
                        end
                        s*=printClause(t.args[end], indent*"\t")
                end
        end
	return s
end



function resolveHelper(kb, query)
	# add negated clause to kb
	dict = index_clauses(kb)

	# for any two clauses 
	# if we can unify, do it and reduce
	 unifiable = []
	 for k=1:length(kb.clauses)                        # [Howl(x), ~Hound(x)]
		 for m=1:length(kb.clauses[k][2])                 # Howl(x)

			 clauses_indices = []
			 if kb.clauses[k][2][m].negated
				 clauses_indices = dict[kb.clauses[k][2][m].op]   # clauses with ~Howl(x)
			 else
				 clauses_indices = dict["~"*kb.clauses[k][2][m].op]
			end

			 for i in clauses_indices          # index of ~Has(w,t), ~Howl(t), ~LS(w)
				 
				 rel_index = findall(x->x.op==kb.clauses[k][2][m].op, kb.clauses[i][2])[1]
				
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
					indices = findall(x->x.op==substituted[2][rel_index].op&&allEqual(x.args,substituted[2][rel_index].args), union)
				else
					indices = findall(x->x.op==substituted[2][m].op&&allEqual(x.args,substituted[2][m].args), union)
				end
					
				deleteat!(union, indices)
				
				if length(union) == 0
                                                printResolution("$(kb.clauses[i][1]),$(kb.clauses[k][1])",
                                                                "$(printUnifiers(unifiable))",
                                                                "$(length(kb.clauses))",
                                                                union)
						println("Reached an empty clause.")
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

function printResolution(nums, theta, c_num, new_c)
	n = 6
	len = length(nums)
	rem = n-len
	spaces = repeat(" ", rem)
	print(nums);print("$(spaces) | ");print("$theta")
	
	n = 25
	len = length(theta)
	rem = n-len
	spaces = repeat(" ", rem)
	print("$spaces[$c_num] ");printCNFClause(new_c);println()
	println("$(repeat("-", 45))")
end

function resolve(kb, query)
	println("------------------ Starting Resolution ------------------\n")

	tell_cnf_terms(kb, [skolemize(negate(toCNF(query)))])
	println("Rule # |           θ $(repeat(" ", 10))|   New Rule")
	println("$(repeat("-", 45))")
	while true
		flag = resolveHelper(kb, query)
		if flag
			println("KB entails query")
			return true
		else
			#sort!(kb.clauses, by=length)
			sort!(kb.clauses, by=x->length(x[2]))
		end
	end
	println("Couldn't prove KB entails query. \nDoes Not entail")
	return false
end

function printResolution()

end
