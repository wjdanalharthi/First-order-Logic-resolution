
# =========================== Sigma
struct Sigma
	C::Set{String}
	F::Set{String}
	R::Set{Tuple{String,Int32}}
end

function Sigma(C::Array{String, 1}, F::Array{String, 1}, 
	       R::Array{Tuple{String,Int64}, 1})
	return Sigma(Set{String}(C), Set{String}(F), Set{Tuple{String, Int32}}(R))
end

function Sigma(R::Array{Tuple{String,Int64}, 1})
	return Sigma(Set{String}(), Set{String}(), Set{Tuple{String, Int32}}(R) )
end

function Sigma(C::Array{Any, 1}, F::Array{String, 1}, R::Array{Tuple{String,Int64}, 1})
        return Sigma(Set{String}(), Set{String}(F), Set{Tuple{String, Int32}}(R) )
end

function Sigma(C::Array{String, 1}, F::Array{Any, 1}, R::Array{Tuple{String,Int64}, 1})
        return Sigma(Set{String}(C), Set{String}(), Set{Tuple{String, Int32}}(R) )
end

# =========================== Quantifier
mutable struct Quantifier
	op::String
	var::String
	args::Any
end

function Quantifier(op::String, var::String)
	return Quantifier(op, var, [])
end

# ========================== Clause
mutable struct Clause
        op::String
        args
        negated::Bool
end

function Clause(op::String, info)
        args = Array{Clause, 1}()
        if length(info) > 0
                args = [toClause(i) for i in info]
        end
        return Clause(op, args, false)
end

function Clause(op::String)
        return Clause(op, Array{Clause, 1}(), false)
end

Base.:(==)(e1::Clause, e2::Clause) = (e1.op == e2.op) && allEqual(e1.args, e2.args)
Base.:(==)(e1::Array{Clause, 1}, e2::Array{Clause, 1}) = allEqual(e1, e2)


# ========================== Knowledge Base
mutable struct KnowledgeBase
        clauses::Array{Tuple{Int32, Array{Clause,1}},1}
end

function KnowledgeBase()
        return KnowledgeBase(Array{Tuple{Int32,Array{Clause,1}},1}())
end

function KnowledgeBase(init::Array{Clause, 1})
        kb = KnowledgeBase()
        tell_cnf_terms(kb, init)
        return kb
end

# ========================== Testing KB and Signature
function get_info(kb::KnowledgeBase, 
		  dict=Dict{String,Set{Any}}(["constants"=>Set{String}(),
						     "functions"=>Set{String}(),
						     "relations"=>Set{Tuple{String, Int32}}()]))
	for clause in kb.clauses
		dict = get_info(clause[2], dict)
	end
	return dict
end

function get_info(formula::Array, dict::Dict{String,Set{Any}})
	if length(formula) == 0
		return dict
	else
		if is_variable(formula[1])
			return get_info(formula[2:end], dict)
		elseif is_constant(formula[1])
			push!(dict["constants"], formula[1].op)
		elseif is_function(formula[1])
			push!(dict["functions"], formula[1].op)
		elseif is_relation(formula[1])
			push!(dict["relations"], ((formula[1].op, length(formula[1].args))))
		else
			error("In get_info(): unexpected operator $(formula[1].op)")
		end

		dict = get_info(formula[1].args, dict)
		return get_info(formula[2:end], dict)
	end
	return dict
end



function verifyTheory(kb::KnowledgeBase, sg::Sigma)
	""" Raise an error if symbols in the theory 
	do not correspond to the signature."""
	dict = get_info(kb)
	if (dict["constants"] == sg.C) &&
		(dict["functions"] == sg.F) &&
		(dict["relations"] == sg.R)
		println("PASS: The knowledge base (theory) corresponds to the given signature")
	else
		error("The knowledge base (theory) does NOT correspond to the given signature")
	end
	nothing
end

