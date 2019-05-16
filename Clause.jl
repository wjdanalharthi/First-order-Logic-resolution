
# ================================ Equality Checks 
function equal(e1, e2)
	if typeof(e1) == Array{Any, 1} && typeof(e2) == Array{Any, 1}
		return true
	elseif typeof(e1) == Array{Clause, 1} && typeof(e2) == Array{Clause, 1}
		if length(e1) == 0 && length(e2) == 0
			return true
		elseif length(e1) == 0 || length(e2) == 0
			return false
		else
			return equal(e1[1], e2[1]) && equal(e1[2:end], e2[2:end])
		end
	elseif e1.op == e2.op
		if length(e1.args) == length(e2.args) && (e1.negated == e2.negated)
			return equal(e1.args, e2.args) 
		else
			return false
		end
	else 
		return false
	end
end

function inArray(a2, c::Clause)
	for j in a2
		if equal(c, j) 
		return true end
	end
	return false
end

function allEqual(a1::Array, a2::Array)
	if length(a1) != length(a2) return false end
	for i in a1
		if inArray(a2, i) 
			continue
		else 
			return false
		end
	end

        for i in a2
                if inArray(a1, i)
                        continue
                else 
                        return false
                end
        end

	return true
end

# ================================ Deep Copying
# WARNING # TODO FIX 
# DEEP COPIES ONLY VARIABLE & CONSTANT ARGS
function copyClause(c::Clause)
	new_c = Clause(c.op)
	new_c.negated = c.negated
	for i in c.args
		i_args = [copyClause(x) for x in i.args]
		append!(new_c.args, Array{Clause, 1}([Clause(i.op, i_args, i.negated)]))
	end
	return new_c
end

function copyClause(c::Array)
	new_arr = Array{Clause, 1}()
	for i in c
		append!(new_arr, Array{Clause, 1}([copyClause(i)]))
	end
	return new_arr
end

function copyClause(q::Quantifier)
	new_q = Quantifier(q.op, q.var)
	new_q.args = copyClause(q.args)
	return new_q

end

# ================================ Conversion to Clause
function extract(symbol::String, arr::Array)
	index = findall(x->x==symbol, arr)[1]
	return arr[1:index-1], arr[index+1:end]
end

function toClause(item)
	if typeof(item) == Clause || typeof(item) == Quantifier return item end
	if length(item) == 0 return item end
        
	# check for operators in the following precedence
        # ==>, |, &, ~, strings and vars
	if typeof(item) == String
		return Clause(item, [])
        end
if impliesTok in item
                l, r = extract(impliesTok, item)
                return Clause(impliesTok, [l, r])
	elseif forallTok in item
		l, r = extract(forallTok, item)
		return Quantifier(forallTok, r[1], toClause(r[2:end]))
	elseif existsTok in item 
                l, r = extract(existsTok, item)
                return Quantifier(existsTok, r[1], toClause(r[2:end]))
	elseif impliesTok in item
                l, r = extract(impliesTok, item)
		return Clause(impliesTok, [l, r])
        elseif orTok in item
                l, r = extract(orTok, item)
		return Clause(orTok, [l, r])
        elseif andTok in item
		l, r = extract(andTok, item)
		return Clause(andTok, [l, r])
        elseif notTok in item
                l, r = extract(notTok, item)
		return Clause(notTok, [r])
        end
	if length(item) == 1 && !(typeof(item) == Array{Any, 1})
		return toClause(item)
	elseif length(item) == 1
		return toClause(item[1])
	end
	return Clause(string(item[1]), item[2:end][1])

end
