include("../hw2.jl")
println("=========================== Barber Problem ===============================")

signature = Sigma([("B", 1), ("S", 2)])

clauses = ["(B(x) & ~S(y,y)) ==> S(x,y)", 
	   "~B(a) | ~S(b,b) | ~S(a,b)"]
clauses = ["∀ x(∀ y((B(x) & ~S(y,y)) ==> S(x,y)))",
	   "∀ x(∀ y(~B(a) | ~S(b,b) | ~S(a,b)))"]
query = "~B(T)"
query = "∀ x(~B(x))"

println("Predicates:")
for i in clauses
        print("\t");println(i)
end
println("Query: $query")
println("Do the predicates entail the query?\n")


println("======================= Knowledge Base & Signature  =======================")

println(signature)

println("Knowledge Base")
cnf_clauses = map(skolemize, map(toCNF, map(toClause, map(lexer, clauses))))
kb = KnowledgeBase(cnf_clauses)
println(kb)

println("Verifying KB corresponds to Signature")
verifyTheory(kb, signature)
println()

println("========================= Starting Resolution ==============================")
query = toClause(lexer(query))
resolve(kb, query)
~                             
