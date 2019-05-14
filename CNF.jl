
# ===================== Returns a Clause in CNF
function toCNF(c::Clause)
        c = eliminate_implications(c)
        c = negateHelper(c)
        return distribute_and_over_or(c)
end

function toCNF(q::Quantifier)
        q.args = toCNF(q.args)
        return q
end
