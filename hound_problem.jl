include("hw2.jl")


clauses = ["Hound(x) ==> Howl(x)",
           "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))",
           "LS(w) ==> ~(Has(w, t) & Howl(t))",
           "Has(John, a) & (Cat(a) | Hound(a))"]
goal = "LS(John) ==> ~(Has(John, b) & Mouse(b))"

cnf_clauses = map(toCNF, map(toClause, map(lexer, clauses)))
query = toClause(lexer(goal))


# Signature 
signature = Sigma(Constants([]), Functions([]), [Relation("Hound", 1),
			   Relation("Howl", 1),
			   Relation("Has", 2),
			   Relation("Cat", 1),
			   Relation("Mouse", 1),
			   Relation("LS", 1)])

println("Knowledge Base")
kb = KnowledgeBase(cnf_clauses)


resolve(kb, query)
