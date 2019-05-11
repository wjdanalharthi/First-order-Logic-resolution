using Printf

function negate(c::Clause)
	return negateHelper(Clause("~", [c]))
end

function negateHelper(c::Clause)
	if c.op == "~"
		arg = c.args[1]
		if arg.op == "~"
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

function associate(op::String, args::Array{Clause,1})
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

function dissociate(operator::String, arguments::Array{Clause,1})
    local result = Array{Clause, 1}([]);
    dissociate_collect(operator, arguments, result);
    return result;
end

function dissociate_collect(operator::String, arguments::Array{Clause,1}, result_array::AbstractVector)
    for argument in arguments
        if (argument.op == operator)
            dissociate_collect(operator, argument.args, result_array);
        else
            push!(result_array, argument);
        end
    end
    nothing;
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

function toCNF(c::Clause)
	c = eliminate_implications(c)
	c = negateHelper(c)
	return distribute_and_over_or(c)
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

function printClause(e::Clause)
    if (length(e.args) == 0)
        return e.op;
    elseif (is_symbol(e.op))
        return @sprintf("%s(%s)", e.op, join(map(printClause, map(Clause, e.args)), ", "));
    elseif (length(e.args) == 1)
        return @sprintf("%s(%s)", e.op, printClause(Clause(e.args[1])));
    else
        return @sprintf("(%s)", join(map(printClause, map(Clause, map(string, e.args))), @sprintf(" %s ", e.op)));
    end
end


function occurrence_check(key::Clause, x, substitutions::Dict)
    if (key == x)
        println("occurrence_check(::Expression, ::Union{Tuple, Vector}, ::Dict) returned true!!!");
        return true;
    else
        if (length(collect(true for element in x if (occurrence_check(key, element, substitutions)))) == 0)
            return false;
        else
            return true;
        end
    end
end


function extend(dict::Dict, key, val)
	println()
	println("$key, $val")
	println()
    local new_dict::Dict = copy(dict);
    new_dict[key] = val;
    return new_dict;
end

function unify_variable(key, x, substitutions::Dict)
    println("$key,    $x,       $substitutions")
    if (key in keys(substitutions))
        return unify(substitutions[key], x, substitutions);
    elseif (x in keys(substitutions))
        return unify(key, substitutions[x], substitutions);
    #elseif (occurrence_check(key, x, substitutions))
    #	    return Dict([]);
    else
        return extend(substitutions, key, x);
    end
end

function unify(e1::String, e2::String, substitutions::Dict)
    println("STRINGS $e1   , $e2    , $substitutions")

    if (e1 == e2)
        return substitutions;
    else
	    return Dict([]);
    end
end

function unify(e1::Clause, e2::Clause, substitutions::Dict)
    println("CLAUSES $e1   , $e2    , $substitutions")
    #if (e1.op == e2.op) && (e1.args == e2.args)
    if equal(e1, e2)
    	return substitutions;
    elseif is_variable(e1)
        return unify_variable(e1, e2, substitutions);
    elseif is_variable(e2)
        return unify_variable(e2, e1, substitutions);
    else
        return unify(e1.args, e2.args, unify(e1.op, e2.op, substitutions));
    end
end

function unify(a1::Array, a2::Array, substitutions::Dict)
	println("ARRAYS $a1     , $a2       ,$substitutions")
    if (a1 == a2)
        return substitutions;
    else
        if (length(a1) == length(a2))
            return unify(a1[2:end], a2[2:end], unify(a1[1], a2[1], substitutions))
        else
		return Dict([])
        end
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
	return length(c.args) == 0 && Base.islowercase(c.op[1])
end

function is_constant(c::Clause)
        return length(c.args) == 0 && Base.isuppercase(c.op[1])
end

function is_relation(c::Clause)
        return !(c.op in OPS) && length(c.args) != 0
end

function MGU1(c1::Clause, c2::Clause)
	if is_constant(c1) && is_constant(c2)
		if c1.op == c2.op return true
		else return false end
	end
	if is_constant(c1) && is_variable(c2)
		return Dict([c2.op=>c1.op])
	end
	if is_constant(c1) && is_relation(c2)
		return false
	end

	if is_variable(c1) && is_constant(c2)
		return Dict([c1.op=>c2.op])
	end
	if is_variable(c1) && is_variable(c2)
		return Dict([c1.op=>c2.op])
	end
	if is_variable(c1) && is_relation(c2)
		# TODO occurance checker 
		return Dict([c1.op=>c2.op])
	end
	
	if is_relation(c1) && is_constant(c2)
		return false
	end
	if is_relation(c1) && is_variable(c2)
		# occurance checker
		return Dict([c2.op=>c1.op])
	end
	if is_relation(c1) && is_relation(c2)
		if c1.op != c1.op return false end
		return MGU(c1.args, c2.args) #TODO Fix
	end
end

function occurs_checker(subt, c1)
	# check if the subt val in c1 vars
	"""
	v = [x for x in values(subt)][1]
	for c in c1
		if is_variable(c)
			if c.op == v return false
			else return true end
		elseif is_relation(c)

		elseif is_constant(c)
		end
	end
	"""
	return true
end

function MGU(c1::Array, k, c2::Array, m)
	dict = Dict()
	for i=1:length(c1[k].args)
		occurs_check, subt = MGUHelper(c1[k].args[i], c2[m].args[i])
		if subt != false
			if occurs_check
				if occurs_checker(subt, c1::Array)
					return subt
				else return () end
			else
				if length(subt) != 0
					dict[subt[1]] = subt[2]
				end
			end
		else
			return ()
		end
	end
	return dict
end

function MGUHelper(c1::Clause, c2::Clause)
        if is_constant(c1) && is_constant(c2)
        	println("cons & cons")
		#TODO what does success mean??
		if c1.op == c2.op return false, (c1.op,c2.op)
                else return false, false end
        end
        if is_constant(c1) && is_variable(c2)
		println("cons & var")
		return false, (c2.op,c1.op)
        end
        if is_constant(c1) && is_relation(c2)
		println("cons & rel")
                return false, false
        end

        if is_variable(c1) && is_constant(c2)
		println("var & cons")
		return false, (c1.op,c2.op)
        end
        if is_variable(c1) && is_variable(c2)
		#println("var & var")
		#if c1.op == c2.op
		#	return false, false
		#end
                return false, (c1.op,c2.op)
        end
        if is_variable(c1) && is_relation(c2)
		println("var & rel")
                # TODO occurance checker
		return true, (c1.op,c2.op)
        end

        if is_relation(c1) && is_constant(c2)
		println("rel & cons")
                return false, false
        end
        if is_relation(c1) && is_variable(c2)
		println("rel & var")
                # TODO occurance checker
                return true, (c2.op,c1.op)
        end
        if is_relation(c1) && is_relation(c2)
		println("rel & rel")
                if c1.op != c1.op return false end
                return MGU(c1.args, c2.args) #TODO Fix
        end
end


function resolveHelper(kb, query)
	# add negated clause to kb
	dict = index_clauses(kb)

	# for any two clauses 
	# if we can unify, do it and reduce
	 unifiable = []
	 for k=1:length(kb.clauses)                        # [Howl(x), ~Hound(x)]
		 print("\n\n******* Current Clause  ")
		 printCNFClause(kb.clauses[k])
		 for m=1:length(kb.clauses[k])                 # Howl(x)
			 
			 print("\n\nCurrent Term ")
			 printCNF(kb.clauses[k][m])

			 clauses_indices = []
			 if kb.clauses[k][m].negated
				 clauses_indices = dict[kb.clauses[k][m].op]   # clauses with ~Howl(x)
			 else
				 clauses_indices = dict["~"*kb.clauses[k][m].op]
			end

			 for i in clauses_indices          # index of ~Has(w,t), ~Howl(t), ~LS(w)
				 print("\nClause with Negated ")
				 printCNF(kb.clauses[k][m]); print(" ==> ")
				 printCNFClause(kb.clauses[i])

				 # find ~Howl(x) at ith index
				 rel_index = findall(x->x.op==kb.clauses[k][m].op, kb.clauses[i])[1]
				 #flag, c = look_for_relation(kb.clauses[i], term.op)
				
				#println("\nc vs rel_index")
				#printCNF(c)
				#printCNF(kb.clauses[i][rel_index])
				
				unifiable = MGU(kb.clauses[k], m, kb.clauses[i], rel_index)
				if length(unifiable) == 0 
					println("\n Not Unifiable")
					continue
				end 
				#println("SUBSTITUION $unifiable")
			
				print("\nUnifying $(kb.clauses[k][m].op) args in: \n\t")
        			printCNFClause(kb.clauses[k]); print("\n\t")
        			printCNFClause(kb.clauses[i])

				# so substitue and get remaining and add to KB
				# first find index of c in kb.clauses[i]
				
				#index = findall(x->x.op==term.op, kb.clauses[i])[1]
				for (key, val) in unifiable
				for w=1:length(kb.clauses[k])
					for j=1:length(kb.clauses[k][w].args)
						if kb.clauses[k][w].args[j].op == key
							kb.clauses[k][w].args[j].op = val
						end
					end
				end
				end
				print("\nUnified $(kb.clauses[k][m].op) by $unifiable\n\t")
				printCNFClause(kb.clauses[k]); print("\n\t")
                                printCNFClause(kb.clauses[i])

				# get remaining
				union = append!(copy(kb.clauses[k]), copy(kb.clauses[i]))
				indices = findall(x->x.op==kb.clauses[k][m].op&&allEqual(x.args,kb.clauses[k][m].args), union)
				deleteat!(union, indices)
			
				print("\nResult Clause: \n\t")
				printCNFClause(union)
				println()
				if length(union) == 0
					println("Union Clause is empty!!")
					return true
				else
					flag = tell(kb, union)
					if flag 
						println("\n ADDED TO KB")
						#return kb
						#dict = index_clauses(kb)
						#else continue end
						return false
					end
				end
			end
		end
	end

	# we found a unification between c1 and c2
	# 1) substitue vars 
	# 2) get remaining terms
	# 3) if remaining terms == [] RETURN SUCCESS
	# 4) otherwise add it to KB and repeat
	return false
end

function resolve(kb, query)
        # add negated clause to kb
        tell_cnf_terms(kb, [toCNF(negate(query))])

	while true
		flag = resolveHelper(kb, query)
		if flag
			println("\nEntails")
			return true
		else
			println("\nFailed")
			#return false
		end
		#println(kb.clauses)
	end
	println("\nDoes Not entail")
	return false
end
