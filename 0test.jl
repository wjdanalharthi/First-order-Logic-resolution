include("Parser.jl")
include("models.jl")

s = "(Malayali(y) & Loves(India, y)) & Boy(y) => Indian(y)"
println(toClause(lexer(s)))

println()
print(toClause(lexer(s)))



print(map(toClause, map(lexer, ["Farmer(Mac)",
              "Rabbit(Pete)",
              "Mother(MrsMac, Mac)",
              "Mother(MrsRabbit, Pete)",
              "(Rabbit(r) & Farmer(f)) => Hates(f, r)",
              "(Mother(m, c)) => Loves(m, c)",
              "(Mother(m, r) & Rabbit(r)) => Rabbit(m)",
              "(Farmer(f)) => Human(f)",
              "(Mother(m, h) & Human(h)) => Human(m)"
	      ])))
