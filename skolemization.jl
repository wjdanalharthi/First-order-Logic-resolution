
function skolemize(q, foralls=[], dict::Dict=Dict([]))
        if typeof(q) != Quantifier
                if typeof(q) == Clause
                        if !(q.op in OPS)
                                if is_variable(q)
                                        if haskey(dict, q.op)
                                                q = copyClause(dict[q.op])
                                        else
                                                dict[q.op] = Clause(next_unique_variable())
                                                q = copyClause(dict[q.op])
                                        end
                                        return q
                                elseif is_relation(q)
                                        return Clause(q.op,
                                                      skolemize(q.args, foralls, dict),
                                                      q.negated)
                                else
                                        return Clause(q.op,
                                                      skolemize(q.args, foralls, dict),
                                                      q.negated)
                                end
                        elseif q.op in OPS
                                # HACK for nested quantifiers
                                if q.op in [orTok, andTok] && typeof(q.args[1]) == Quantifier && q.args[1].args.op in [orTok, andTok]
                                                rem = copyClause(q.args[2:end])
                                                rem = [copyClause(x) for x in q.args[2:end]]
                                                rem = q.args[2:end]
                                                append!(rem, q.args[1].args.args)

                                                y= Clause(q.op, rem)
                                                k = Quantifier(q.args[1].op, q.args[1].var, y)
                                                return skolemize(k)
                                end
                                return Clause(q.op,
                                              skolemize(q.args, foralls, dict),
                                              q.negated)
                        else
                                error("skolemize(): Unexpected clause operator $(q.op)")
                        end
                elseif typeof(q) == Array{Clause, 1} || typeof(q) == Array{Any, 1}
                        if length(q) == 0
                                return q
                        else
                                new_args = [skolemize(clause, foralls, dict) for clause in q]
                                return new_args
                        end

                else
                        error("skolemize(): Unexpected type $(typeof(q))")
                end
        elseif q.op == forallTok
                new_var = next_unique_variable()
                dict[q.var] = Clause(new_var)
                q.var = new_var
                append!(foralls, [q])
                skolemize_args = skolemize(q.args, foralls, dict)
                q.args = skolemize_args
                return q.args
        elseif q.op == existsTok
                if length(foralls) == 0
                        unique_cons = next_unique_constant()
                        dict[q.var] = Clause(unique_cons)
                        return skolemize(q.args, foralls, dict)
                end
                forall_vars = [x.var for x in foralls]
                vars_clauses = [Clause(x) for x in forall_vars]
                unique_function_name =  next_unique_function()
                new_function = Clause(unique_function_name, vars_clauses)
                dict[q.var] = new_function
                return skolemize(q.args, foralls, dict)
        else
                error("skolemize(): Unexpected operator $(q.op)")
        end
end

function next_unique_function(ref::AbstractVector=func_counter)
        ref[2] = iterate(ref[1], ref[2])[2]
        return "f$(ref[2])"
end

function next_unique_variable(ref::AbstractVector=var_counter)
        ref[2] = iterate(ref[1], ref[2])[2]
        return "v$(ref[2])"
end

function next_unique_constant(ref::AbstractVector=cons_counter)
        ref[2] = iterate(ref[1], ref[2])[2]
        return "C$(ref[2])"
end
