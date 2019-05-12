include("hw2.jl")


clauses = ["(B(x) & ~S(y,y)) ==> S(x,y)", "~B(a) | ~S(b,b) | ~S(a,b)"]
goal = "~B(T)"

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
print(kb)

resolve(kb, query)
~                                                                                                                                                           
~                          
