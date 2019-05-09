include("Parser.jl")

varTok = "var"
lparenTok = "("
rparenTok = ")"
notTok = "~"
andTok = "&"
orTok = "|"
impliesTok = "==>"
iffTok = "<=>"
forallTok = "forall"
existsTok = "exists"
trueTok = "true"
falseTok = "false"
sigTok = "sig"

OPS = [impliesTok, andTok, orTok, notTok]

# =============================== Clause ============================
mutable struct Clause
        op::String
	args
	parents
end

function Clause(op::String, info::Array, parents::Array)
	args = []
	if length(info) > 0
		args = [toClause(i) for i in info]
	end
	return Clause(op, args, parents)
end


function Clause(op::String, info::Array)
        args = []
        if length(info) > 0
                args = [toClause(i) for i in info]
        end
        return Clause(op, args, nothing)
end

function Clause(op::String, info::String)
        args = [toClause(i) for i in info]
        return Clause(op, args, nothing)
end

"""
function Base.show(io::IO, c::Clause)
	if length(c.args) == 0 println(c.op) 
	elseif !(c.op in OPS) 
		x = string(c.args[1])
		for arg in c.args[2:end]
			x = x * ", " * string(arg)
		end
		return c.op * "(" * x * ")"
	elseif c.op == notTok
		if !(c.args[1] in OPS) return notTok * string(c.args[1])
		else return notTok * "(" * string(c.args[1]) * ")" end
	else
		res = ""
		if c.args[1] in OPS
			res = "(" * string(c.args[1]) * ")"
		else
			res = string(c.args[1])
		end
		res = res * " " * c.op * " "
		if c.args[2].op in OPS
			res = res * "(" * string(c.args[2]) * ")"
		else  
			res = res * string(c.args[2])
		end
		print(res)
	end
end

function Base.show(io::IO, t::Clause)
        printcHelper(t, "")
end

"""

function printcHelper(t::Clause, indent::String)
        if !(t.op in OPS)
                print("$indent $(t.op)(")
                for i=1:length(t.args)-1
                        print("$(t.args[i].op),")
                end
                println("$(t.args[end].op))")
        else
                println("$indent $(t.op)")
                for i=1:length(t.args)
                        printcHelper(t.args[i], indent*"\t")
                end
        end
end

function extract(symbol::String, arr::Array)
	index = findall(x->x==symbol, arr)[1]
	return arr[1:index-1], arr[index+1:end]
end

function toClause1(item)
	if typeof(item) == Clause return item end
	
	# check for operators in the following precedence
	# ==>, |, &, ~, strings and vars
	if impliesTok in item
		l, r = extract(impliesTok, item)
		return Clause(impliesTok, toClause(l, r), [])
	elseif orTok in item  
		l, r = extract(orTok, item)
		return Clause(orTok, toClause(l, r), [])
	elseif andTok in item
                l, r = extract(andTok, item)
                return Clause(andTok, toClause(l, r), [])
	elseif notTok in item
                l, r = extract(notTok, item)
                return Clause(notTok, toClause(l, r), [])
	elseif typeof(item) == String
		return Clause(item, [], [])
	end

	if length(item) == 1 return Clause(item[0], [], []) end
	return Clause(item[0], toClause(item[1:end][0]), [])

end

function toClause(item)
	if typeof(item) == Clause return item end

        # check for operators in the following precedence
        # ==>, |, &, ~, strings and vars
	if typeof(item) == String
		println("String $item")
		return Clause(item, [])
        end
        if impliesTok in item
		println("==> $item")
                l, r = extract(impliesTok, item)
		return Clause(impliesTok, [l, r])
        elseif orTok in item
		println("| $item")
                l, r = extract(orTok, item)
		return Clause(orTok, [l, r])
        elseif andTok in item
		println("& $item")
		l, r = extract(andTok, item)
		return Clause(andTok, [l, r])
        elseif notTok in item
		println("~ $item")
                l, r = extract(notTok, item)
		return Clause(notTok, [r])
        end
	if length(item) == 1 
		println("letter $item")
		return toClause(item[1])
	end
	println("something else $(item[1]), $([item[2:end][1]])")
	return Clause(string(item[1]), item[2:end][1])

end
