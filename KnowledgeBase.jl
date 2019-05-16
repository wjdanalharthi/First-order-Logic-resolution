
# ================================ Adding Clauses to KB

function tell(kb::KnowledgeBase, clauses::Array)
        if length(clauses) == 0
                return true
        end

        clauses = remove_duplicates(clauses)
        if exists_in_kb(kb, clauses) return false end

        append!(kb.clauses, [(length(kb.clauses)+1, clauses)])
        return true
end

function tell_cnf_terms(kb, arr)
	for i in arr
		if i.op == orTok
			c = internalize_negation(i.args)
			tell(kb, c)
		elseif is_relation(i)
			tell(kb, [i])
		elseif i.op == notTok
			c = internalize_negation(i.args[1])
			tell(kb, [c])
                elseif i.op == andTok
                        #or_args = [x for x in c if x.op == "|"]
                        ind = findall(x->x.op=="|", i.args)
			ind_and = findall(x->x.op!="|", i.args)
			tell_cnf_terms(kb, i.args[ind])

                        for c in ind_and
				tell(kb, [i.args[c]])
                        end     
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
		if c[j].op == notTok
			c[j] = c[j].args[1]
			c[j].negated = true
		end
	end
	return c
end

function remove_duplicates(arr)
	no_dups = Array{Clause, 1}()
        for i in arr
                if !inArray(no_dups, i)
                        append!(no_dups, [i])
                end
        end
	return no_dups
end

function exists_in_kb(kb, arr)
        for i in kb.clauses
		if allEqual(i[2], arr) return true end
        end
	return false
end

# ================================ Indexing KB Clauses
function find_all_relations(c)
	return [x.op for x in c]
end

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
		all_rels = find_all_relations(i[2])
		for j in all_rels
			if !haskey(d, j)
				d[j] = Array{Int32, 1}()
				d["~"*j] = Array{Int32, 1}()
			end
		end
	end
	
	for key in keys(d)
		for i=1:length(kb.clauses)
			flag, c = look_for_relation(kb.clauses[i][2], key)
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
