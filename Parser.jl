
"""
Tokens are:
exists
forall
and
or
implies
not
TRUE / FALSE ???
Variables
parans
"""

varTok = "var"
lparenTok = "("
rparenTok = ")"
andTok = "and"
orTok = "or"
impliesTok = "implies"
iffTok = "iff"
forallTok = "forall"
existsTok = "exists"
trueTok = "true"
falseTok = "false"
sigTok = "sig"

function lexer(s::String)
	#return [tokenize(i) for i in splitStatement(s)]
	return parse(splitStatement(s))
end

"""
function Base.show(io::IO, x::Array{String, 2})
	print("[")
	for i in x[1:end-1]
		print(i * ", ")
	end
	println(x[end] * "]")

end
"""

function splitStatement(s::String)
	s = "(" * s * ")"
	for i in ['(', ')', '&', '|', '~', "==>", "<=>"]
		s = replace(s, i => " $i ") 
	end
	s = replace(s, "," => " ")
	return map(string, split(s))
end

function tokenize(s::String)
	if s == lparenTok return (lparenTok,) end
	if s == rparenTok return (rparenTok,) end
	if s == andTok return (andTok,) end
	if s == orTok return (orTok,) end
	if s == impliesTok return (impliesTok,) end
	if s == iffTok return (iffTok,) end
	if s == forallTok return (forallTok,) end
	if s == existsTok return (existsTok,) end
	if s == trueTok return (trueTok,) end
	if s == falseTok return (falseTok,) end
	if length(s) > 1 return (sigTok, s) end
	if length(s) == 1 return (varTok, s) end
end

function pop(l::Array, i::Integer)
	if length(l) == 0 return nothing, l end
	if i < 1 || i > length(l) return nothing, l end
	return l[i], append!(l[1:i-1], l[i+1:end])
end

function parse1(l::Array)
	input_stack = copy(l)
	curr, input_stack = pop(input_stack, 1)
	if length(l) == 0 return [] end
	if curr[1] == lparenTok
		exp = []
		while input_stack[1][1] != rparenTok
			append!(exp, parse(input_stack))
		end
		curr, input_stack = pop(input_stack, 1)
		return exp
	else
		res = parse(input_stack)
		#println("Curr [$curr], res $res")
		return append!([curr], res)
	end
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


