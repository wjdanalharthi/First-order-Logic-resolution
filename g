S(x,y), ~B(x), S(y,y)
~B(a), ~S(b,b), ~S(a,b)

julia> resolve(kb, query)

******* Current Clause  S(x,y), ~B(x), S(y,y)
Current Term S(x,y)
Clause with Negated S(x,y) ==> ~B(a), ~S(b,b), ~S(a,b)
Unifying S args in: 
	S(x,y), ~B(x), S(y,y)
	~B(a), ~S(b,b), ~S(a,b)
Unified S by Dict{Any,Any}("x"=>"b","y"=>"b")
	S(b,b), ~B(b), S(b,b)
	~B(a), ~S(b,b), ~S(a,b)
Result Clause: 
	~B(b), ~B(a), ~S(a,b)

 ADDED TO KB

Failed


******* Current Clause  S(b,b), ~B(b), S(b,b)
Current Term ~B(b)
Clause with Negated ~B(b) ==> B(t)
Unifying B args in: 
	S(b,b), ~B(b), S(b,b)
	B(t)
Unified B by Dict{Any,Any}("b"=>"t")
	S(t,t), ~B(t), S(t,t)
	B(t)
Result Clause: 
	S(t,t), S(t,t)

 ADDED TO KB

Failed


******* Current Clause  ~B(a), ~S(b,b), ~S(a,b)
Current Term ~B(a)
Clause with Negated ~B(a) ==> B(t)
Unifying B args in: 
	~B(a), ~S(b,b), ~S(a,b)
	B(t)
Unified B by Dict{Any,Any}("a"=>"t")
	~B(t), ~S(b,b), ~S(t,b)
	B(t)
Result Clause: 
	~S(b,b), ~S(t,b)

 ADDED TO KB

Failed


******* Current Clause  S(b,b), ~B(b), S(b,b)
Clause with Negated S(b,b) ==> ~S(b,b), ~S(t,b)
Unifying S args in: 
	S(b,b), ~B(b), S(b,b)
	~S(b,b), ~S(t,b)
Unified S by Dict{Any,Any}("b"=>"b")
	S(b,b), ~B(b), S(b,b)
	~S(b,b), ~S(t,b)
Result Clause: 
	~B(b), ~S(t,b)

 ADDED TO KB

Failed


******* Current Clause  ~B(t), ~S(b,b), ~S(t,b)
Current Term ~S(b,b)
Clause with Negated ~S(b,b) ==> S(b,b)
Unifying S args in: 
	~B(t), ~S(b,b), ~S(t,b)
	S(b,b)
Unified S by Dict{Any,Any}("b"=>"b")
	~B(t), ~S(b,b), ~S(t,b)
	S(b,b)
Result Clause: 
	~B(t), ~S(t,b)

 ADDED TO KB

Failed


******* Current Clause  ~B(t), ~S(b,b), ~S(t,b)
Current Term ~S(t,b)
Clause with Negated ~S(t,b) ==> S(b,b), ~B(b), S(b,b)
Unifying S args in: 
	~B(t), ~S(b,b), ~S(t,b)
	S(b,b), ~B(b), S(b,b)
Unified S by Dict{Any,Any}("t"=>"b","b"=>"b")
	~B(b), ~S(b,b), ~S(b,b)
	S(b,b), ~B(b), S(b,b)
Result Clause: 
	~B(b), ~B(b)

 ADDED TO KB

Failed


******* Current Clause  ~B(b), ~S(b,b), ~S(b,b)

Current Term ~B(b)
Clause with Negated ~B(b) ==> B(t)
Unifying B args in: 
	~B(b), ~S(b,b), ~S(b,b)
	B(t)
Unified B by Dict{Any,Any}("b"=>"t")
	~B(t), ~S(t,t), ~S(t,t)
	B(t)
Result Clause: 
	~S(t,t), ~S(t,t)

 ADDED TO KB

Failed


******* Current Clause  B(t)
Clause with Negated B(t) ==> ~B(t)
Unifying B args in: 
	B(t)
	~B(t)
Unified B by Dict{Any,Any}("t"=>"t")
	B(t)
	~B(t)
Result Clause: 
	[]

Union Clause is empty!!

Entails
true

julia> 

