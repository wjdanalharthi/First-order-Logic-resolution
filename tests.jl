include("hw2.jl")

# ======================= Verifying Theory of Signature
println("$(repeat("=", 15)) KB & Signature Tests $(repeat("=", 15))")

sigma = Sigma(["John", "T"], [("g", 1), ("bar", 1)], [("Tree", 1), ("Taller", 2), ("Human", 1)])
println(sigma)

clauses = [["∀ t((Human(John) & Tree(t)) ==> ~Taller(John, t))",
           "∀ x(∃ t(Human(x) ==> (Tree(y) & Taller(x, y))))"], 
	   ["∀ t((Human(John) & Tree(t)) ==> ~Taller(John, t))",
           "∀ x(∃ t(Human(x) ==> (Tree(y) & Shorter(x, y))))"],
	   ["∀ t((Human(John) & Tree(t)) ==> ~Taller(John, (f(t))))",
           "∀ x(∃ t(Human(x) ==> (Tree(y) & Taller(x, y))))"], 
	   ["∀ t((Human(John) & Tree(t)) ==> ~Taller(John, C))",
           "∀ x(∃ t(Human(x) ==> (Tree(y) & Taller(x, y))))"]]
explainations = ["All relations, functions, and constants in KB are in Sigma",
		"KB contains a Relation that is NOT in Sigma",
		"KB contains a Function that is NOT in Sigma",
		"KB contains a Constant that is NOT in Sigma"]
for i=1:length(clauses)
	println("($i)")
	kb = KnowledgeBase(map(skolemize, map(toCNF, map(toClause, map(lexer, clauses[i])))))
	println(kb)
	try
        	verifyTheory(kb, sigma)
		println(explainations[i])
	catch
        	println("FAIL")
		println(explainations[i])
	end
	println()
end


# ======================= Skolemization 
println("$(repeat("=", 15)) Skolemization Tests $(repeat("=", 15))")
clauses = ["∃ x(∀ y(∀ z(∃ u (∀ v(∃ w(P(x,y,z,u,v,w)))))))",
	   "∀ x(∃ y(∃ z((~P(x, y) & Q(x, z)) | R(x, y, z))))",
	   "∀ x(∀ y(∃ z(∀ w(∃ u(P(x, y) & (Q(z,w) | R(u)))))))",
	   "∀ x(Philo(x) ==> ∃ y(Book(y) & Write(x, y)))",
	   "∀ x(∀ y((Philo(x) & StudentOf (y, x)) ==> ∃ z(Book(z) & Write(x, z) & Read(y, z))))",
	   "∃ x(∃ y(Philo(x) & StudentOf(y, x)))"]
for i=1:length(clauses)
	println("($i)")
	s = toCNF(toClause(lexer(clauses[i])))
	print("\tStatement:\t");printCNF(s);println()
	skolemized_s = skolemize(s)
	print("\tSkolemized:\t");printCNF(skolemized_s);println("\n")
	reset_counters()
end

# ======================= CNF form
println("$(repeat("=", 15)) CNF Tests $(repeat("=", 15))")
clauses = []


# ======================= Unification MGU
println("$(repeat("=", 15)) Unification Tests $(repeat("=", 15))")
clauses = [["P((f(x)))", "P((g(y)))"],
	   ["P(x)", "P((f(y)))"],
	   ["p((f(a)),(g(X)))", "p(Y,Y)"],
	   ["P(x, (f(x,(g(y)))), y)", "P(a, z, u)"]]
for i=1:length(clauses)
	cnf = map(toCNF, map(toClause, map(lexer, clauses[i])))
	print("Unify: ");printCNF(cnf[1]);print("\t");printCNF(cnf[2]);println()
	resolvants = MGU(cnf[1], cnf[2])
	if length(resolvants) == 2
		unifiers, flip = resolvants
	else
		unifiers = resolvants
	end
	if unifiers == false
		println("Not Unifiable")
		break
	end
	print("MGU: ");print(printUnifiers(unifiers))
	println("\n")
end

# ======================= Resolution 
# (check Examples directory for bigger resolution problems)
println("$(repeat("=", 15)) Resolution Tests $(repeat("=", 15))")
println("(1)")
clauses = ["∀ x(I(x) ==> H(x))",
	   "~H(D)"]
query = "~I(D)"
cnf_clauses = map(skolemize, map(toCNF, map(toClause, map(lexer, clauses))))
kb = KnowledgeBase(cnf_clauses)
println(kb)
println("Does the KB entail $query?")
query = toClause(lexer(query))
resolve(kb, query)

println("(2)")
clauses = ["Mother(Lulu, Fifi)", "Alive(Lulu)",
	   "∀ x(∀ y(Mother(x,y) ==> Parent(x,y)))",
	   "∀ x(∀ y((Parent(x,y) & Alive(x)) ==> Older(x,y)))"]
query = "Older(Lulu, Fifi)"
cnf_clauses = map(skolemize, map(toCNF, map(toClause, map(lexer, clauses))))
kb = KnowledgeBase(cnf_clauses)
println(kb)
println("Does the KB entail $query?")
query = toClause(lexer(query))
resolve(kb, query)



