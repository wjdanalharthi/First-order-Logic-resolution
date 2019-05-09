include("Parser.jl")
include("Clause.jl")
include("func.jl")
include("utils.jl")

example = ["Hound(x) ==> Howl(x)",
           "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))",
           "LS(w) ==> ~(Has(w, t) & Howl(t))",
           "Has(John, v) & (Cat(v) | Hound(v))"]

example_query = "LS(John) ==> ~(Has(John, m) & Mouse(m))"

# turn into expression
e = map(toClause, map(lexer, example))

# turn into CNF
cnf = map(toCNF, e)


for i in cnf
	println(i)
	println()
end
# use unification
# apply resolution!
