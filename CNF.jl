
# ===================== Returns a Clause in CNF
function toCNF(c::Clause)
	c = eliminate_implications(c)
	c = negateHelper(c)
	return distribute_and_over_or(c)
end

function toCNF(q::Quantifier)
	q.args = toCNF(q.args)

	#quants = push_quantifiers(q)
        #q = put_back(q, quants, nothing)
	#c = q
	#println("GOT $q");println()
	return q
end

function push_quantifiers(q, d::Array=[])
	if typeof(q) != Quantifier
		if typeof(q) == Array || typeof(q) == Array{Any,1} || typeof(q) == Array{Clause,1}
			if length(q) == 0
				return d
			end
			d = push_quantifiers(q[1], d)
			d = push_quantifiers(q[2:end], d)
			return d
		elseif is_symbol(q)
                        return d	
		else
			return push_quantifiers(q.args, d)
		end
	end
	append!(d, [(q.op, q.var)])
	d = push_quantifiers(q.args, d)
	return d
end

function put_back(q, d, nest=nothing)
	if nest == nothing
		nest = Quantifier(d[1][1], d[1][2], nothing)
		p = nest
		for i in d[2:end-1]
				p.args = Quantifier(i[1], i[2], nothing)
				p = p.args.args 
		end
		p.args = Quantifier(d[end][1], d[end][2], put_back(q, d, nest))
		return nest
	end
	if typeof(q) == Quantifier
		return put_back(q.args,d,nest)
	elseif typeof(q) == Clause
		return Clause(q.op, put_back(q.args, d, nest), q.negated)
	elseif typeof(q) == Array || typeof(q) == Array{Any,1} || typeof(q) == Array{Clause,1}
		if length(q) == 0
			return q
		end
		return [put_back(x, d, nest) for x in q]
	else
		error("wrd")
		end
end

