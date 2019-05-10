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

function MGU(c1::Array, c2::Array)
	for i=1:length(c1)
		println("checking $(c1[i]), $(c2[i])")
		subt = MGUHelper(c1[i], c2[i])
		if subt != false
			return subt
		end
	end
	return false
end

function MGUHelper(c1::Clause, c2::Clause)
        if is_constant(c1) && is_constant(c2)
        	println("cons & cons")
		if c1.op == c2.op return true
                else return false end
        end
        if is_constant(c1) && is_variable(c2)
		println("cons & var")
                return Dict([c2.op=>c1.op])
        end
        if is_constant(c1) && is_relation(c2)
		println("cons & rel")
                return false
        end

        if is_variable(c1) && is_constant(c2)
		println("var & cons")
                return Dict([c1.op=>c2.op])
        end
        if is_variable(c1) && is_variable(c2)
		println("var & var")
		if c1.op == c2.op
			return false
		end
                return Dict([c1.op=>c2.op])
        end
        if is_variable(c1) && is_relation(c2)
		println("var & rel")
                # TODO occurance checker
                return Dict([c1.op=>c2.op])
        end

        if is_relation(c1) && is_constant(c2)
		println("rel & cons")
                return false
        end
        if is_relation(c1) && is_variable(c2)
		println("rel & var")
                # occurance checker
                return Dict([c2.op=>c1.op])
        end
        if is_relation(c1) && is_relation(c2)
		println("rel & rel")
                if c1.op != c1.op return false end
                return MGU(c1.args, c2.args) #TODO Fix
        end
end

function get_relation_args(c, rel::String)
        if typeof(c) == Array{Clause, 1}
                if length(c) == 0
                        return false
                else
                        return look_for_relation(c[1], rel) || look_for_relation(c[2:end], rel)
                end
        elseif typeof(c) == Array{Any, 1}
                return false
        elseif c.op in OPS
                return look_for_relation(c.args, rel)
        else
                if c.op == rel
                        return c.args
                else
                        return look_for_relation(c.args, rel)
                end
        end
end

function resolve(kb, query)
	# add negated clause to kb
	tell_cnf_terms(kb, [toCNF(negate(query))])
	dict = index_clauses(kb)

	# for any two clauses 
	# if we can unify, do it and reduce
	 unifiable = []
	 for c1 in kb.clauses
		for c2 in kb.clauses
			println("Checking")
			println("\t $c1")
			println("\t $c2")
			if c1 == c2
				continue
			end
			for term in c1
				clauses = dict[term.op]
				for c in clauses
					args = get_relation_args(c, term.op)
					println("comparing relation $(term.op)")
					unifiable = MGU(c1, args)
                        		if length(unifiable) != 0 
                       	        		break
					end

                        	end
			end
		end
		if length(unifiable) != 0
			break
		end
	end

	# we found a unification between c1 and c2
	# 1) substitue vars 
	# 2) get remaining terms
	# 3) if remaining terms == [] RETURN SUCCESS
	# 4) otherwise add it to KB and repeat

end
