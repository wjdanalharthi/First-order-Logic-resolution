
lparenTok = "("
rparenTok = ")"

notTok = "~"
andTok = "&"
orTok = "|"
impliesTok = "==>"
iffTok = "<=>"

forallTok = "∀"
existsTok = "∃"

OPS = [impliesTok, andTok, orTok, notTok, iffTok]

var_counter = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)]
func_counter = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)]
cons_counter = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)]

function reset_counters()
	var_counter = copy([Base.Iterators.countfrom(BigInt(1)), BigInt(-1)])
	func_counter = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)]
	cons_counter = [Base.Iterators.countfrom(BigInt(1)), BigInt(-1)]
end
