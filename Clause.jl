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
	negated::Bool
end

function Clause(op::String, info::Array)
	args = []
	if length(info) > 0
		args = [toClause(i) for i in info]
	end
	return Clause(op, args, false)
end


function Clause(op::String, info::Array)
        args = []
        if length(info) > 0
                args = [toClause(i) for i in info]
        end
        return Clause(op, args, false)
end

function Clause(op::String, info::String)
        args = [toClause(i) for i in info]
        return Clause(op, args, false)
end

function Clause(op::String)
	return Clause(op, [], false)
end

function equal(e1, e2)
	if typeof(e1) == Array{Any, 1} && typeof(e2) == Array{Any, 1}
		return true
	elseif typeof(e1) == Array{Clause, 1} && typeof(e2) == Array{Clause, 1}
		if length(e1) == 0 && length(e2) == 0
			return true
		elseif length(e1) == 0 || length(e2) == 0
			return false
		else
			return equal(e1[1], e2[1]) || equal(e1[2:end], e2[2:end])
		end
	elseif e1.op == e2.op
		if length(e1.args) == length(e2.args)
			return equal(e1.args, e2.args) 
		else
			return false
		end
	else 
		return false
	end
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
        printCNF(t, "")
end
"""

function printTree(t::Clause, indent::String)
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

function printCNF(t::Any, indent::String="")
	#if t.op in ["forall", "exists"]
	#	print("$(t.op) $(t.var)(")
	#	printCNF(t.args, indent)
	#	print(")")
	if !(t.op in OPS)
                print("$(t.op)(")
                for i=1:length(t.args)-1
                        print("$(t.args[i].op),")
                end
                print("$(t.args[end].op))")
        else
                #print(" $(t.op) ")
                #for i=1:length(t.args)
                #        printcHelper(t.args[i], indent*"\t")
                #end
		if t.op == "~"
			print("$(t.op)")
	                for i=1:length(t.args)
        	                printCNF(t.args[i], indent*"\t")
                	end
		else
			printCNF(t.args[1], indent*"\t")
			print(" $(t.op) ")
                        for i=2:length(t.args)-1
                                printCNF(t.args[i], indent*"\t")
                        	print(" $(t.op) ")
			end
			printCNF(t.args[end], indent*"\t")
			#printcHelper(t.args[2:end], indent*"\t")
		end

        end
	println()
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
	#println("item $item")
	if typeof(item) == Clause return item end

        # check for operators in the following precedence
        # ==>, |, &, ~, strings and vars
	if typeof(item) == String
		#println("string $item")
		return Clause(item, [])
        end
	if "forall" in item
		l, r = extract("forall", item)
		return Quantifier("forall", r[1], toClause(r[2:end]))
	elseif "exits" in item 
                l, r = extract("exits", item)
                return Quantifier("exits", r[1], toClause(r[2:end]))
	elseif impliesTok in item
                l, r = extract(impliesTok, item)
		return Clause(impliesTok, [l, r])
        elseif orTok in item
                l, r = extract(orTok, item)
		return Clause(orTok, [l, r])
        elseif andTok in item
		l, r = extract(andTok, item)
		return Clause(andTok, [l, r])
        elseif notTok in item
                l, r = extract(notTok, item)
		return Clause(notTok, [r])
        end
	if length(item) == 1 && !(typeof(item) == Array{Any, 1})
		#println("letter $item")
		return toClause(item)
	elseif length(item) == 1
		return toClause(item[1])
	end
	#println("something else $item,   $(item[1]),  $(item[2:end][1])")
	return Clause(string(item[1]), item[2:end][1])

end
