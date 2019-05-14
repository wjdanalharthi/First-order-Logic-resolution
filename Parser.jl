
function lexer(s::String)
	return parse(splitStatement(s))
end

function splitStatement(s::String)
	s = "(" * s * ")"
	for i in ['(', ')', '&', '|', '~', "==>", "<=>"]
		s = replace(s, i => " $i ") 
	end
	s = replace(s, "," => " ")
	return map(string, split(s))
end

function parse(input_stack::Array)
	curr = input_stack[1]
	deleteat!(input_stack, 1)
	
	if curr == lparenTok
                exp = []
                while input_stack[1] != rparenTok
			append!(exp, [parse(input_stack)])
                end
		deleteat!(input_stack, 1)
		return exp
        else
		return string(curr)
        end
end


