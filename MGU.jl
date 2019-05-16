
# ========================= Finds unifiders between two clauses
function MGU(c1::Clause, c2::Clause)
        return MGU([c1], 1, [c2], 1)
end

function MGU(c1::Array, k, c2::Array, m)
        dict = Dict()
        flip = false
	for i = 1:length(c1[k].args)
                flip = false
		result = MGUHelper(c1[k].args[i], c2[m].args[i])
		if length(result) == 2
                	subt, flip = result
		else
			subt = result
		end
                if subt != false
                                if length(subt) != 0
					dict[subt[1]] = copyClause(subt[2])
                                end
                else
			return Dict([])
                end
        end
        return dict, flip
end


function MGUHelper(c1::Clause, c2::Clause)
        #println("$(c1.op), $(c2.op)")
    if is_constant(c1) && is_constant(c2)
                if c1.op == c2.op return (c1, c2), false
        else return false end
    end
    if is_constant(c1) && is_variable(c2)
                return (c2, c1), true
    end
    if is_constant(c1) && is_function(c2)
        return false
    end

    if is_variable(c1) && is_constant(c2)
                return (c1, c2), false
    end
    if is_variable(c1) && is_variable(c2)
                #if c1.op == c2.op
                #       return false, false
                #end
        return (c1, c2), false
    end
    if is_variable(c1) && is_function(c2)
                if occurs(c1.op, c2.args)
                                return false
                end
                return (c1, c2), false
    end

    if is_function(c1) && is_constant(c2)
        return false
    end
    if is_function(c1) && is_variable(c2)
                # TODO flip clauses!
                if occurs(c2.op, c1.args)
                                return false
                end
        return (c2, c1), true
    end
    if is_function(c1) && is_function(c2)
        if c1.op != c2.op return false end
	return MGU([c1], 1, [c2], 1) 
    end
end

function occurs(var::String, args::Array)
        # check if the subt val in c1 vars

        for arg in args
                if arg.op == var return true end
        end
        return false
end
