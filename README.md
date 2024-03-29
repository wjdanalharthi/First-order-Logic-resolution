
## First-order Logic Resolution

## Project Description
this project implements a First-order Logic resolution program. That includes a Parser, CNF and Skolemization conversions, and Unification.

## How to Run
- to run the unit tests use `julia tests.jl`
- to run the examples use `julia examples\barber.jl` and `julia examples\hound_problem.jl`
- to use indivisual functions, make sure to `include("hw2.jl")` 

## Project Structure
- `hw2.jl`: all modules and libraries imported
- `globals.jl`: global variables such as unique variable names counter
- `structs.jl`: holds the definitions of all structs (Clause, Knowledge Base, Quantifier, Signature), as well as the verifyTheory() test
- `Parser.jl`: parses a string and returns objects of Clauses and/or Quantifiers
- `Clause.jl` and `KnowledgeBase.jl`: both contain Clauses or KB specific functions, such as Equal and Copy
- `identifiers.jl`: contains the functions used to identify different types of objects/strings
- `operations.jl`: contains functions used for Boolean algebra and operations
- `printers.jl`: holds different printing functions for different object types and functions
- `CNF.jl`: converts a Clause to CNF form
- `skolemization.jl`: converts a CNF clause to a Skolem form
- `MGU.jl`: returns general unifiers for two clauses
- `resolution.jl`: uses all above to resolve a query given a KB

## Examples and Clarifications
- a Clause instance is basically a Literal but it was too late to change the name ;/
- a KnowledgeBase holds an array of array of Clauses. A Knowledgebase represents {} in FOL (conjunctions), and the arrays of Clauses (Literals) represent [] (disjunctions). So a KB is a conjunction of disjunctions. 
- a Clause has an operator, and a list of arguments. A Clause can be
	- variable: lowercase operator and zero arguments
	- functions: lowercase operator with arguments
	- constant: uppercase operator with no arguments
	- relation: uppercase operator with arguments
	- symbol: is any of the above
- a Quantifier holds an operator, variable, and a Clause
- String statements must be passed to lexer() to parse and separate the different components and combine by precedence. Then passed to toClause() to convert to a Clause object. 
- Skolemization here does two things, get rid of quantifiers properly and standarize variables such that every new variable we need is a unique one in the KB 
- the current resolution algorithm prints redundant steps  
- the unifier shows redundant substituions (x->x or C->C) but they do not affect the algorithm

## Assignment Requirements
- Q1: `Parser.jl` and `structs.jl`
- Q2: `CNF.jl` and `skolemization.jl`
- Q3: `MGU.jl`
- Q4: `resolution.jl` and `examples\barber.jl`

## References:
most examples and tests are inspired from

- AIMA book
- https://eli.thegreenplace.net/2018/unification/
- https://www.cs.toronto.edu/~sheila/384/w11/Lectures/csc384w11-KR-tutorial.pdf
- https://courses.cs.washington.edu/courses/cse473/01sp/slides/fol-inference-4.pdf
- https://www21.in.tum.de/teaching/logik/SS17/Slides/resolution-fol.pdf 

