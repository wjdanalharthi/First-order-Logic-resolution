include("Parser.jl")
include("Clause.jl")
include("func.jl")
include("utils.jl")
include("KnowledgeBase.jl")

#p1 = Quantifier("forall", "x", "Hound(x) ==> Howl(x)", [])
#p2 = Quantifier("forall", "y", "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))", [Quantifier("forall", "z", "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))", [])])


o = "forall x (Hound(x) ==> Howl(x))"
oo = "exits y (forall z (Has(y, z) & Cat(z)) ==> (forall u ~(Has(y,u) & Mouse(u))))"
ooo = "exits v (Has(John, v) & (Cat(v) | Hound(v)))"

example = ["Hound(x) ==> Howl(x)",
           "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))",
           "LS(w) ==> ~(Has(w, t) & Howl(t))",
           "Has(John, a) & (Cat(a) | Hound(a))"]
example_query = "LS(John) ==> ~(Has(John, b) & Mouse(b))"

#example = ["Hound(x) ==> Howl(x)"]
#example_query = "~Hound(x) | Howl(y)"

#example = ["LS(w) ==> ~(Has(w, t) & Howl(t))"]
#example_query = "LS(John) ==> ~(Has(John, b) & Mouse(b))"

# turn into expression
cnf_clauses = map(toCNF, map(toClause, map(lexer, example)))
query = toClause(lexer(example_query))

kb = KnowledgeBase(cnf_clauses)

# turn into CNF
#kb.clauses = map(toCNF, kb.clauses)
#query = toCNF(negate(query))

#for i in kb.clauses
#	printCNF(i, "")
	#println(i)
#	println()
#end

# use unification
# apply resolution!
