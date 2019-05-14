function negate(c::Clause)
        return negateHelper(Clause(notTok, [c]))
end

function negateHelper(c::Clause)
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
        if (operator == andTok)
            return Clause("TRUE");
        elseif (operator == orTok)
            return Clause("FALSE");
        else
                error("associate(): Unknown quantifier operator $(q.op)")
        end
        elseif (length(dis_args) == 1)
                return dis_args[1]
        else
                return Clause(op, dis_args)
        end
end

function dissociate(operator::String, arguments::Array)
    local result = Array{Any,1}([]);
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
        others = collect(a for a in a.args);
        rest = associate("|", others);
        return associate("&", collect(distribute_and_over_or(Clause("|", [conjunction_arg, rest]))
                                        for conjunction_arg in conjunction.args));
    elseif (e.op == "&")
        return associate("&", map(distribute_and_over_or, e.args));
    else
        return e;
    end
end
