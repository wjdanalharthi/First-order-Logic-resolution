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

function is_symbol(s::String)
    if length(s) == 0
        return false
    else
        return Base.isletter(s[1])
    end
end

