
"""
struct Constants
	cons::Array
end
struct Functions
	func::Array
end
struct Relation
	name::String
	arity::Int
end
"""

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

function Base.show(io::IO, sigma::Sigma)
	println("Signature");print("\t")
	print("C: ");print(sigma.C);print("\n\t")
	print("F: ");print(sigma.F);print("\n\t")
	print("R: ");print(sigma.R);print("\n\t")
end

function Base.show(io::IO, s::Set)
	r = "("
	for i in s
		r*="$i, "
	end
	if length(r) != 1 r = r[1:end-2] end
	r*=")"
	print(r)

end

mutable struct Quantifier
	op::String
	var::String
	args::Any
end

struct Operator
	op::String
	args::Array
end

function get_info(kb::KnowledgeBase, 
		  dict=Dict{String,Set{Any}}(["constants"=>Set{String}(),
						     "functions"=>Set{String}(),
						     "relations"=>Set{Tuple{String, Int32}}()]))
	for clause in kb.clauses
		dict = get_info(clause, dict)
	end
	return dict
end

function get_info(formula::Array{Clause, 1}, dict::Dict{String,Set{Any}})
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

