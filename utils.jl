
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


struct Sigma
	C::Constants
	F::Functions
	R::Array{Relation, 1}
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

