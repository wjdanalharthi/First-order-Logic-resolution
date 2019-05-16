function Base.show(io::IO, kb::KnowledgeBase)
	println("Knowledge Base")
        printCNFClause([x[2] for x in kb.clauses])
end

function Base.show(io::IO, sigma::Sigma)
        println("Signature");print("\t")
	print("C: $(printSet(sigma.C))");print("\n\t")
	print("F: $(printSet(sigma.F))");print("\n\t")
	print("R: $(printSet(sigma.R))");print("\n\t")
end

function printSet(s::Set)
        r = "("
        for i in s
                r*="$i, "
        end
        if length(r) != 1 r = r[1:end-2] end
        r*=")"
        #print(r)
	return r
end

function Base.show(io::IO, d::Dict)
        s = "{"
        for (k, v) in d
                s *= "$k=>$v, "
        end
        s = s[1:end - 2]
        s *= "}"
        print(s)
end

function printUnifiers(d::Dict)
	if length(d) == 0
		return "{ϕ}"
	end 
	s = "{"
        for (k, v) in d
                s *= printClause(k)
                s *= "->"
                s *= printClause(v)
                s *= ", "
        end
        s = s[1:end - 2]
        s *= "}"
        return s
end

function printClause(t::Any, indent::String = "")
    s = ""
        if !(t.op in OPS)
        if length(t.args) == 0
            s *= "$(t.op)"
        else
            if t.negated
                s *= "~"
            end
            curr = "$(t.op)("
            for i = 1:length(t.args)
                curr *= "$(t.args[i].op)"
                if length(t.args[i].args) != 0
                    curr *= "("
                    for a = 1:length(t.args[i].args)
                        curr *= "$(t.args[i].args[a].op),"
                    end
                    curr = curr[1:end - 1]
                    curr *= "), "
                else
                    curr *= ", "
                end
            end
            curr = curr[1:end - 2]
            curr *= ")"
            s *= curr
                end
    else
        if t.op == "~"
            s *= "$(t.op)"
            for i = 1:length(t.args)
                s *= printClause(t.args[i], indent * "\t")
            end
        else
            s *= printClause(t.args[1], indent * "\t")
            s *= " $(t.op) "
            for i = 2:length(t.args) - 1
                s *= printClause(t.args[i], indent * "\t")
                s *= " $(t.op) "
            end
            s *= printClause(t.args[end], indent * "\t")
        end
    end
        return s
end


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
        if typeof(t) == Quantifier
                printCNF(t)

        elseif !(t.op in OPS)
                if length(t.args) == 0
                        print("$(t.op)")
                else
                if t.negated
                        print(notTok)
                end
                curr = "$(t.op)("
                for i=1:length(t.args)
                        curr*="$(t.args[i].op)"
                        if length(t.args[i].args) != 0
                                curr*= "("
                                for a=1:length(t.args[i].args)
                                        curr*="$(t.args[i].args[a].op),"
                                end
                                curr = curr[1:end-1]
                                curr*="), "
                        else
                                curr*=", "
                        end
                end
                curr=curr[1:end-2]
                curr*=")"
                print(curr)
                end
        else
                if t.op == notTok
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
                end
        end
end

function printCNFClause(c::Array{Array{Clause,1},1})
        if length(c) == 0
                println("[]")
                return
        end
        for arr in c
                print("\t");printCNFClause(arr)
                print("\n")
        end
end

function printCNFClause(arr::Array)
        if length(arr) == 0
                println("[]")
                return
        end
        for i in arr[1:end-1]
                printCNF(i)
                print(", ")
        end
        printCNF(arr[end])
end

function printCNF(q::Quantifier)
        print("$(q.op).$(q.var)(")
        printCNF(q.args)
        print(")")
end

function printResolution(nums, theta, c_num, new_c, f = true)
        n = 6
        len = length(nums)
        rem = n - len
        spaces = repeat(" ", rem)
        print("$nums");print("$(spaces) | ");print("$theta")

        n = 25
        len = length(theta)
        rem = n - len
        spaces = repeat(" ", rem)
        print("$spaces[$c_num] ");printCNFClause(new_c);println()
        if f
                println("$(repeat("-", 45))")
        end
end

function printEnd(s)
        d = repeat("=", 76)
        println(d)
        println(s)
        println(d)

end
