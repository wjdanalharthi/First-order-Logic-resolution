include("../hw2.jl")


signature = Sigma([("B", 1), ("S", 2)])
println(signature)


clauses = ["(B(x) & ~S(y,y)) ==> S(x,y)", 
	   "~B(a) | ~S(b,b) | ~S(a,b)"]
clauses = ["∀ x(∀ y((B(x) & ~S(y,y)) ==> S(x,y)))",
	   "∀ x(∀ y(~B(a) | ~S(b,b) | ~S(a,b)))"]
	   #"~(∃ x(∃ y(B(x) & ~S(y,y) & ~S(x,y)))"]
cnf_clauses = map(skolemize, map(toCNF, map(toClause, map(lexer, clauses))))

kb = KnowledgeBase(cnf_clauses)
println("Knowledge Base")
println(kb)

verifyTheory(kb, signature)
println()

query = "~B(T)"
query = "∀ x(~B(x))"
query = toClause(lexer(query))

#resolve(kb, query)
