
# ========================= Finds unifiders between two clauses
function MGU(c1::Clause, c2::Clause)
        return MGU([c1], 1, [c2], 1)
end

function MGU(c1::Array, k, c2::Array, m)
        dict = Dict()
        flip = false
        for i = 1:length(c1[k].args)
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


# TODO FIX RELS
function MGUHelper(c1::Clause, c2::Clause)
        #println("$(c1.op), $(c2.op)")
    if is_constant(c1) && is_constant(c2)
                #println("cons & cons")
                #TODO what does success mean??
                if c1.op == c2.op return false, (c1, c2)
        else return false, false end
    end
    if is_constant(c1) && is_variable(c2)
                #println("cons & var")
                # TODO flip clauses!
                return false, (c2, c1), true
    end
    if is_constant(c1) && is_function(c2)
                #println("cons & rel")
        return false, false
    end

    if is_variable(c1) && is_constant(c2)
                #println("var & cons")
                return false, (c1, c2)
    end
    if is_variable(c1) && is_variable(c2)
                #println("var & var")
                #if c1.op == c2.op
                #       return false, false
                #end
        return false, (c1, c2)
    end
    if is_variable(c1) && is_function(c2)
                #println("var & rel")
                # TODO occurance checker
                if occurs(c1.op, c2.args)
                                return false, false
                end
                return true, (c1, c2)
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
        return true, (c2, c1), true
    end
    if is_function(c1) && is_function(c2)
                #println("rel & rel")
        if c1.op != c1.op return false end
        return MGU(c1.args, c2.args) #TODO Fix
    end
end

function occurs(var::String, args::Array)
        # check if the subt val in c1 vars

        for arg in args
                if arg.op == var return true end
        end
        return false
end
