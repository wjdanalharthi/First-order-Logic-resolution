include("Clause.jl")
get_new_variable = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)];

mutable struct KnowledgeBase
        clauses::Array{Clause, 1}
end

function KnowledgeBase()
	return KnowledgeBase([])
end

function KnowledgeBase(init::Array{Clause, 1})
	kb = KnowledgeBase()
	for i in init
		tell(kb, i)
	end
	return kb
end

function tell(kb::KnowledgeBase, predicate::Clause)
	push!(kb.clauses, predicate)
end

function ask(kb::KnowledgeBase, query::Clause)
	return fol_bc_ask(kb, query);
end

function retract(kb::KnowledgeBase, c::Clause)
    for (index, item) in enumerate(kb.clauses)
        if (item == c)
            deleteat!(kb.clauses, index);
            break;
        end
    end
end


function fol_bc_ask(kb::KnowledgeBase, query::Clause)
	return fol_bc_or(kb, query, Dict())
end

function fol_bc_or(kb::KnowledgeBase, query::Clause, 
		   theta::Dict, get_new_variable::AbstractVector)
	thetas = ()
	for rule in kb.clauses
		l, r =  
	end
end

function parse_logic_clause(c::Clause)
	if is_logic_symbol(c.op)
		return Array{Clause, 1}([]), c;
	else
		l, r = e.args
		return conjuncts(l), r
	end
end

function standardize_variables(c::Clause, ref::AbstractVector,
			      dict::Union{Nothing, Dict}=nothing)
	if typeof(dict) <: Nothing
		dict = Dict()
	end

	if is_variable(c.op)
		if haskey(dict, c)
			return dict[c]
		else
			ref[2] = iterate(ref[1], ref[2])[2]
			new_var = Clause("v_$(repr(counter[2]))")
			dict[c] = new_var
			return var
		end
	else
		return Clause(c.op,
			      collect(standardize_variables(arg, dict=dict) for arg in c.args)...,)
	end
end

function is_symbol(s::String)
	if length(s) == 0
		return false
	else
		return Base.isletter(s[1])
	end
end

function is_variable(v::String)
	return is_symbol(v) && Base.islowercase(v[1])
end
