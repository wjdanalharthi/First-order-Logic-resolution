include("hw2.jl")

# Verifying Theory of Signature


# Parsing 


# Skolemization 
s = toClause(lexer("∃ x(∀ y(∀ z(∃ u (∀ v(∃ w(P(x,y,z,u,v,w)))))))"))
printCNF(s);println()
skolemized_s = skolemize(s)
printCNF(skolemized_s)

# CNF form


# Unification MGU


# Resolution (check Examples directory for bigger resolution problems)

