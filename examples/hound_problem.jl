include("../hw2.jl")

println("=========================== Hound Problem ================================")

signature = Sigma(["John"], [], [("Hound", 1), ("Howl", 1),
			     	 ("Has", 2), ("Cat", 1),
			     	 ("Mouse", 1), ("LS", 1)])
clauses = ["Hound(x) ==> Howl(x)",
           "(Has(y, z) & Cat(z)) ==> ~(Has(y,u) & Mouse(u))",
           "LS(w) ==> ~(Has(w, t) & Howl(t))",
           "Has(John, a) & (Cat(a) | Hound(a))"]

clauses = ["∀ x(Hound(x) ==> Howl(x))",
	    "∀ y(∀ z((Has(y, z) & Cat(z)) ==> ~(∃ u(Has(y,u) & Mouse(u)))))",
	    "∀ w(LS(w) ==> ~(∃ t(Has(w, t) & Howl(t))))",
	   "∀ a(Has(John, a) & (Cat(a) | Hound(a)))"]
query = "LS(John) ==> ~(Has(John, b) & Mouse(b))"
query = "LS(John) ==> ~(∃ b(Has(John, b) & Mouse(b)))"

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
