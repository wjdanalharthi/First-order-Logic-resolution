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
	
	return kb
end


function Base.show(io::IO, kb::KnowledgeBase)
	printCNFClause(kb.clauses)
end


function tell_cnf_terms(kb, arr)
        for i in arr
		if i.op == "|"
			c = internalize_negation(i.args)
			tell(kb, c)
		elseif is_relation(i)
			tell(kb, [i])
		elseif i.op == "~"
			c = internalize_negation(i.args[1])
			tell(kb, [c])
                else
			tell(kb, [i.args[1]])
			tell_cnf_terms(kb, i.args[2:end])
                end
        end
end

function internalize_negation(c::Clause)
	c.negated = true
	return c
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

function remove_duplicates(arr)
	no_dups = Array{Clause, 1}()
        for i in arr
                #rem = append!(copy(predicates)[1:i-1], copy(predicates)[i+1:end]) 
                if !inArray(no_dups, i)
                        append!(no_dups, [i])
                end
        end
	return no_dups
end

function exists_in_kb(kb, arr)
        for i in kb.clauses
                if allEqual(i, arr) return true end
        end
	return false
end

function tell(kb::KnowledgeBase, clauses::Array)
	# first find all Relations and create index
	if length(clauses) == 0
		return true
	end

	clauses = remove_duplicates(clauses)
	if exists_in_kb(kb, clauses) return false end

	append!(kb.clauses, [clauses])
	return true
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
				d["~"*j] = Array{Int32, 1}()
			end
		end
	end
	
	for key in keys(d)
		for i=1:length(kb.clauses)
			flag, c = look_for_relation(kb.clauses[i], key)
			if flag
				if !c.negated
					append!(d[key], i)
				else
					append!(d["~"*key], i)
				end
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

