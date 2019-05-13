include("../hw2.jl")

signature = Sigma(["John"], [], [("Hound", 1), ("Howl", 1),
			     	 ("Has", 2), ("Cat", 1),
			     	 ("Mouse", 1), ("LS", 1)])
println(signature)

clauses = ["Hound(x) ==> Howl(x)",
           "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))",
           "LS(w) ==> ~(Has(w, t) & Howl(t))",
           "Has(John, a) & (Cat(a) | Hound(a))"]
cnf_clauses = map(toCNF, map(toClause, map(lexer, clauses)))

kb = KnowledgeBase(cnf_clauses)
println("Knowledge Base")
println(kb)

verifyTheory(kb, signature)
println()

query = "LS(John) ==> ~(Has(John, b) & Mouse(b))"
query = toClause(lexer(query))

#resolve(kb, query)
