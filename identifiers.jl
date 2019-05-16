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

function is_symbol(c::Clause)
	return is_relation(c) || is_variable(c) || is_constant(c) || is_function(c)
end

