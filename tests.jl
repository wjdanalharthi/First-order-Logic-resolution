include("hw2.jl")

# Verifying Theory of Signature
sigma = Sigma(["John", "T"], [("g", 1), ("bar", 1)], [("Tree", 1), ("Taller", 2), ("Human", 1)])
clauses = ["(Human(John) & Tree(T)) ==> ~Taller(John, T)", 
	   "∀ x(Human(x) ==> ∃ y(Tree(y) & Taller(x, y)))"]
kb = KnowledgeBase(map(skolemize, map(toCNF, map(toClause, map(lexer, clauses)))))
verifyTheory(kb, sigma)

# Parsing 


# Skolemization 
s = toClause(lexer("∃ x(∀ y(∀ z(∃ u (∀ v(∃ w(P(x,y,z,u,v,w)))))))"))
printCNF(s);println()
skolemized_s = skolemize(s)
printCNF(skolemized_s)

# CNF form


# Unification MGU


# Resolution (check Examples directory for bigger resolution problems)

