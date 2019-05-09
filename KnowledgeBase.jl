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

function retract(kb::KnowledgeBase, c::Clause)
    for (index, item) in enumerate(kb.clauses)
        if (item == c)
            deleteat!(kb.clauses, index);
            break;
        end
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

