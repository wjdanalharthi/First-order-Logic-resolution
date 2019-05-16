function negate(c::Clause)
        return negateHelper(Clause(notTok, [c]))
end

function negateHelper(c)
        if c.op == notTok
                arg = c.args[1]
                if typeof(arg) == Quantifier
                                return negate(arg)
		elseif arg.op == notTok
                                return negateHelper(arg.args[1])
                elseif arg.op == andTok
                                return associate(orTok, map(negate, arg.args))
                elseif arg.op == orTok
                                return associate(andTok, map(negate, arg.args))
                else
                                return c
                end
	elseif typeof(c) == Quantifier
		return Quantifier(c.op, c.var, negateHelper(c.args))
        elseif (is_symbol(c) || (length(c.args) == 0))
                return c
        else
                return Clause(c.op, map(negateHelper, c.args))

        end
end

"""
function negateHelper(q::Quantifier)
        return negate(q)
end
"""

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
        if (length(dis_args) == 1)
                return dis_args[1]
        else
                return Clause(op, dis_args)
        end
end

function dissociate(op, args::Array)
    result = Array{Any,1}([]);
    dissociate_collect(op, args, result);
    return result;
end

function dissociate_collect(op, args::Array, results)
	for arg in args
		if (arg.op == op)
			dissociate_collect(op, arg.args, results);
		else
			push!(results, arg);
		end
	end
end

function eliminate_implications(q::Quantifier)
        return Quantifier(q.op, q.var, eliminate_implications(q.args))
end

function eliminate_implications(c::Clause)
	if length(c.args) == 0 || is_symbol(c)
		return c;
	end
	args = map(eliminate_implications, c.args);
	a = first(args);
	b = last(args);
	if (c.op == "==>")
		return Clause(orTok, [b, Clause(notTok, [a])]);
	elseif (c.op == "<=>")
		return Clause(andTok, [Clause(orTok, [a, Clause(notTok, [b])]), Clause(orTok, [b, Clause(notTok, [a])])]);
	else
		if !(c.op in [andTok, orTok, notTok])
		    error("eliminate_implications(): Unexpected operator $(c.op)");
	    end
        return Clause(c.op, args);
    end
end

function distribute_and_over_or(c::Clause)
	if (c.op == orTok)
		a = associate(orTok, c.args);
		if (a.op != orTok)
			return distribute_and_over_or(a);
        	end
		conjuncts = findfirst(x->x.op==andTok, a.args);
		if (conjuncts === nothing)
			return a;
		else
			conjuncts = a.args[conjuncts];
        	end
		others = collect(a for a in a.args if (!(a == conjuncts)));
		rest = associate(orTok, others);
		return associate(andTok, [distribute_and_over_or(Clause("|", [arg, rest])) for arg in conjuncts.args]);
	elseif (c.op == andTok)
		return associate(andTok, map(distribute_and_over_or, c.args));
	else
		return c
	end
end
