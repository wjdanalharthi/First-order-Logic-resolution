include("Clause.jl")
get_new_variable = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)];

mutable struct KnowledgeBase
        clauses::Array{Array{Clause,1},1}
end

function KnowledgeBase()
	return KnowledgeBase(Array{Array{Clause,1},1}())
end

function KnowledgeBase(init::Array{Clause, 1})
	kb = KnowledgeBase()
	tell_cnf_terms(kb, init)
	
	#for i in init
	#	tell(kb, i)
	#end
	return kb
end

function tell_cnf_terms(kb, arr)
        for i in arr
                if i.op == "|"
			c = internalize_negation(i.args)
			tell(kb, c)
                else
			tell(kb, internalize_negation([i.args[1]]))
			tell_cnf_terms(kb, i.args[2:end])
                end
        end
end

function internalize_negation(c)
	for j=1:length(c)
		if c[j].op == "~"
			c[j] = c[j].args[1]
			c[j].negated = true
		end
	end
	return c
end

"""
function tell_cnf_terms(kb, arr)
        for i in arr
                if i.op == "~"
                        clause = i.args[1]
                        clase.negated = true
                        tell(kb, clause)
                elseif is_relation(i)
                        tell(kb, [i])
                else
                        tell_cnf_terms(kb, i.args)
                end
        end
end
"""

function tell(kb::KnowledgeBase, predicates::Array)
	# first find all Relations and create index
	append!(kb.clauses, [predicates])
end

function retract(kb::KnowledgeBase, c::Clause)
    for (index, item) in enumerate(kb.clauses)
        if (item == c)
            deleteat!(kb.clauses, index);
            break;
        end
    end
end

function is_relation(c::Clause)
	return !(c.op in OPS) && length(c.args) != 0 
end

"""
function find_all_relations(c::Array, lib::Array{String, 1}=Array{String,1}())
	if length(c) == 0
		return lib
	elseif is_relation(c[1])
		if !(c[1].op in lib)
			append!(lib, [string(c[1].op)])
		end
		return find_all_relations(c[2:end], lib)
	elseif c[1].op == "~"
		lib = find_all_relations([c[1]], lib)
		return find_all_relations(c[2:end], lib)

	end
	#for i in c.args
	#	lib = find_all_relations(i, lib) 
	#end
	return lib
end
"""

function find_all_relations(c)
	return [x.op for x in c]
end

# create indices for better unification
function look_for_relation(c, rel::String)
        if typeof(c) == Array{Clause, 1}
                if length(c) == 0
                        return false, nothing
                else
                        f1, c1 = look_for_relation(c[1], rel)
			f2, c2 = look_for_relation(c[2:end], rel)
			if f1
				return f1, c1
			else
				return f2, c2
			end
                end
        elseif typeof(c) == Array{Any, 1}
                return false, nothing
        elseif c.op in OPS
                return look_for_relation(c.args, rel)
        else
                if c.op == rel
                        return true, c
                else
                        return look_for_relation(c.args, rel)
                end
        end
end

function index_clauses(kb::KnowledgeBase)
	d = Dict()
	for i in kb.clauses
		all_rels = find_all_relations(i)
		for j in all_rels
			if !haskey(d, j)
				d[j] = Array{Int32, 1}()
			end
		end
	end
	
	for key in keys(d)
		for i=1:length(kb.clauses)
			flag, c = look_for_relation(kb.clauses[i], key)
			if flag && c.negated
				append!(d[key], i)
			end
		end
	end

	return d
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

