
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


struct Quantifier
	op::String
	args::Array
end

struct Operator
	op::String
	args::Array
end

