# flang
Factorio Interpreter in Lua

# description

The EBNF language definition can be found in `base\parser.lua`.

The flow from source file to symbol table is as follows:

[source file] -> [characters] -> `base\scanner.lua` -> `base\lexer.lua` -> [tokens] -> `base\parser.lua` -> [nodes] -> `base\interpreter.lua` -> [symbol table]


#### symbol table

The symbol table is a mapping between variable names and values.

# drivers
The drivers run different functionality modules of the language. For example, the `_lexerDriver.lua` will run the lexer and print tokens of the source input file.

# example

A complete example of Flang can be found in the `samples/complete.flang` file. Running `lua _interpreterCompleteDriver.lua` will run this example and assertions. An example successful output (with lexer tokens) is printed below:

```
[Command: lua C:\Users\jrcontre\Documents\github\flang\_interpreterCompleteDriver.lua]
====== source file =========
alpha15 = 15
boolTrue = true

bFive = alpha15 / 3

pi = 3.141592

aFalse = 3 > 4
bTrue = 1 < 2
cTrue = 5 >= 5
dTrue = 6 <= 6

eTrue = 2 *3 > 4 - 2

shouldBeFalse=!true

under_score_var = 12
false2 = !( 3>+4)

modulus_3 = 18 % 5
modulus_2 = -1 % 3

======= lexer tokens =========
{line: '0'	 column: '0'	 type 'Identifier'	'alpha15'}
{line: '0'	 column: '8'	 type '='		'='}
{line: '0'	 column: '10'	 type 'Number'		'15'}
{line: '1'	 column: '1'	 type 'Identifier'	'boolTrue'}
{line: '1'	 column: '10'	 type '='		'='}
{line: '1'	 column: '12'	 type 'true'		'true'}
{line: '3'	 column: '1'	 type 'Identifier'	'bFive'}
{line: '3'	 column: '7'	 type '='		'='}
{line: '3'	 column: '9'	 type 'Identifier'	'alpha15'}
{line: '3'	 column: '17'	 type '/'		'/'}
{line: '3'	 column: '19'	 type 'Number'		'3'}
{line: '5'	 column: '1'	 type 'Identifier'	'pi'}
{line: '5'	 column: '4'	 type '='		'='}
{line: '5'	 column: '6'	 type 'Number'		'3.141592'}
{line: '7'	 column: '1'	 type 'Identifier'	'aFalse'}
{line: '7'	 column: '8'	 type '='		'='}
{line: '7'	 column: '10'	 type 'Number'		'3'}
{line: '7'	 column: '12'	 type '>'		'>'}
{line: '7'	 column: '14'	 type 'Number'		'4'}
{line: '8'	 column: '1'	 type 'Identifier'	'bTrue'}
{line: '8'	 column: '7'	 type '='		'='}
{line: '8'	 column: '9'	 type 'Number'		'1'}
{line: '8'	 column: '11'	 type '<'		'<'}
{line: '8'	 column: '13'	 type 'Number'		'2'}
{line: '9'	 column: '1'	 type 'Identifier'	'cTrue'}
{line: '9'	 column: '7'	 type '='		'='}
{line: '9'	 column: '9'	 type 'Number'		'5'}
{line: '9'	 column: '11'	 type '>='		'>='}
{line: '9'	 column: '14'	 type 'Number'		'5'}
{line: '10'	 column: '1'	 type 'Identifier'	'dTrue'}
{line: '10'	 column: '7'	 type '='		'='}
{line: '10'	 column: '9'	 type 'Number'		'6'}
{line: '10'	 column: '11'	 type '<='		'<='}
{line: '10'	 column: '14'	 type 'Number'		'6'}
{line: '12'	 column: '1'	 type 'Identifier'	'eTrue'}
{line: '12'	 column: '7'	 type '='		'='}
{line: '12'	 column: '9'	 type 'Number'		'2'}
{line: '12'	 column: '11'	 type '*'		'*'}
{line: '12'	 column: '12'	 type 'Number'		'3'}
{line: '12'	 column: '14'	 type '>'		'>'}
{line: '12'	 column: '16'	 type 'Number'		'4'}
{line: '12'	 column: '18'	 type '-'		'-'}
{line: '12'	 column: '20'	 type 'Number'		'2'}
{line: '14'	 column: '1'	 type 'Identifier'	'shouldBeFalse'}
{line: '14'	 column: '14'	 type '='		'='}
{line: '14'	 column: '15'	 type '!'		'!'}
{line: '14'	 column: '16'	 type 'true'		'true'}
{line: '16'	 column: '1'	 type 'Identifier'	'under_score_var'}
{line: '16'	 column: '17'	 type '='		'='}
{line: '16'	 column: '19'	 type 'Number'		'12'}
{line: '17'	 column: '1'	 type 'Identifier'	'false2'}
{line: '17'	 column: '8'	 type '='		'='}
{line: '17'	 column: '10'	 type '!'		'!'}
{line: '17'	 column: '11'	 type '('		'('}
{line: '17'	 column: '13'	 type 'Number'		'3'}
{line: '17'	 column: '14'	 type '>'		'>'}
{line: '17'	 column: '15'	 type '+'		'+'}
{line: '17'	 column: '16'	 type 'Number'		'4'}
{line: '17'	 column: '17'	 type ')'		')'}
{line: '19'	 column: '1'	 type 'Identifier'	'modulus_3'}
{line: '19'	 column: '11'	 type '='		'='}
{line: '19'	 column: '13'	 type 'Number'		'18'}
{line: '19'	 column: '16'	 type '%'		'%'}
{line: '19'	 column: '18'	 type 'Number'		'5'}
{line: '20'	 column: '1'	 type 'Identifier'	'modulus_2'}
{line: '20'	 column: '11'	 type '='		'='}
{line: '20'	 column: '13'	 type '-'		'-'}
{line: '20'	 column: '14'	 type 'Number'		'1'}
{line: '20'	 column: '16'	 type '%'		'%'}
{line: '20'	 column: '18'	 type 'Number'		'3'}
{line: '20'	 column: '19'	 type 'Eof'		'	EOF'}
======= nodes ========
creating program node
creating var node {line: '0'	 column: '0'	 type 'Identifier'	'alpha15'}
creating num node {line: '0'	 column: '10'	 type 'Number'		'15'}
creating assign node: {'nodeType: {'Var'}  value: {'alpha15'}'} and token {'alpha15'}
creating var node {line: '1'	 column: '1'	 type 'Identifier'	'boolTrue'}
creating boolean node {line: '1'	 column: '12'	 type 'true'		'true'}
creating assign node: {'nodeType: {'Var'}  value: {'boolTrue'}'} and token {'boolTrue'}
creating var node {line: '3'	 column: '1'	 type 'Identifier'	'bFive'}
creating var node {line: '3'	 column: '9'	 type 'Identifier'	'alpha15'}
creating num node {line: '3'	 column: '19'	 type 'Number'		'3'}
creating bin op node {line: '3'	 column: '17'	 type '/'		'/'}
creating assign node: {'nodeType: {'Var'}  value: {'bFive'}'} and token {'bFive'}
creating var node {line: '5'	 column: '1'	 type 'Identifier'	'pi'}
creating num node {line: '5'	 column: '6'	 type 'Number'		'3.141592'}
creating assign node: {'nodeType: {'Var'}  value: {'pi'}'} and token {'pi'}
creating var node {line: '7'	 column: '1'	 type 'Identifier'	'aFalse'}
creating num node {line: '7'	 column: '10'	 type 'Number'		'3'}
creating num node {line: '7'	 column: '14'	 type 'Number'		'4'}
creating comparator node: {'{line: '7'	 column: '12'	 type '>'		'>'}'}
creating assign node: {'nodeType: {'Var'}  value: {'aFalse'}'} and token {'aFalse'}
creating var node {line: '8'	 column: '1'	 type 'Identifier'	'bTrue'}
creating num node {line: '8'	 column: '9'	 type 'Number'		'1'}
creating num node {line: '8'	 column: '13'	 type 'Number'		'2'}
creating comparator node: {'{line: '8'	 column: '11'	 type '<'		'<'}'}
creating assign node: {'nodeType: {'Var'}  value: {'bTrue'}'} and token {'bTrue'}
creating var node {line: '9'	 column: '1'	 type 'Identifier'	'cTrue'}
creating num node {line: '9'	 column: '9'	 type 'Number'		'5'}
creating num node {line: '9'	 column: '14'	 type 'Number'		'5'}
creating comparator node: {'{line: '9'	 column: '11'	 type '>='		'>='}'}
creating assign node: {'nodeType: {'Var'}  value: {'cTrue'}'} and token {'cTrue'}
creating var node {line: '10'	 column: '1'	 type 'Identifier'	'dTrue'}
creating num node {line: '10'	 column: '9'	 type 'Number'		'6'}
creating num node {line: '10'	 column: '14'	 type 'Number'		'6'}
creating comparator node: {'{line: '10'	 column: '11'	 type '<='		'<='}'}
creating assign node: {'nodeType: {'Var'}  value: {'dTrue'}'} and token {'dTrue'}
creating var node {line: '12'	 column: '1'	 type 'Identifier'	'eTrue'}
creating num node {line: '12'	 column: '9'	 type 'Number'		'2'}
creating num node {line: '12'	 column: '12'	 type 'Number'		'3'}
creating bin op node {line: '12'	 column: '11'	 type '*'		'*'}
creating num node {line: '12'	 column: '16'	 type 'Number'		'4'}
creating num node {line: '12'	 column: '20'	 type 'Number'		'2'}
creating bin op node {line: '12'	 column: '18'	 type '-'		'-'}
creating comparator node: {'{line: '12'	 column: '14'	 type '>'		'>'}'}
creating assign node: {'nodeType: {'Var'}  value: {'eTrue'}'} and token {'eTrue'}
creating var node {line: '14'	 column: '1'	 type 'Identifier'	'shouldBeFalse'}
creating boolean node {line: '14'	 column: '16'	 type 'true'		'true'}
creating negation node {line: '14'	 column: '15'	 type '!'		'!'}
creating assign node: {'nodeType: {'Var'}  value: {'shouldBeFalse'}'} and token {'shouldBeFalse'}
creating var node {line: '16'	 column: '1'	 type 'Identifier'	'under_score_var'}
creating num node {line: '16'	 column: '19'	 type 'Number'		'12'}
creating assign node: {'nodeType: {'Var'}  value: {'under_score_var'}'} and token {'under_score_var'}
creating var node {line: '17'	 column: '1'	 type 'Identifier'	'false2'}
creating num node {line: '17'	 column: '13'	 type 'Number'		'3'}
creating num node {line: '17'	 column: '16'	 type 'Number'		'4'}
creating unary op node {line: '17'	 column: '15'	 type '+'		'+'}
creating comparator node: {'{line: '17'	 column: '14'	 type '>'		'>'}'}
creating negation node {line: '17'	 column: '10'	 type '!'		'!'}
creating assign node: {'nodeType: {'Var'}  value: {'false2'}'} and token {'false2'}
creating var node {line: '19'	 column: '1'	 type 'Identifier'	'modulus_3'}
creating num node {line: '19'	 column: '13'	 type 'Number'		'18'}
creating num node {line: '19'	 column: '18'	 type 'Number'		'5'}
creating bin op node {line: '19'	 column: '16'	 type '%'		'%'}
creating assign node: {'nodeType: {'Var'}  value: {'modulus_3'}'} and token {'modulus_3'}
creating var node {line: '20'	 column: '1'	 type 'Identifier'	'modulus_2'}
creating num node {line: '20'	 column: '14'	 type 'Number'		'1'}
creating unary op node {line: '20'	 column: '13'	 type '-'		'-'}
creating num node {line: '20'	 column: '18'	 type 'Number'		'3'}
creating bin op node {line: '20'	 column: '16'	 type '%'		'%'}
creating assign node: {'nodeType: {'Var'}  value: {'modulus_2'}'} and token {'modulus_2'}
====== PARSE TREE =====
program
1
   statement assign: alpha15
      nodeType: {'Num'}  value: {'15'}
      var: {'alpha15'}
2
   statement assign: boolTrue
      boolean: {'true'}
      var: {'boolTrue'}
3
   statement assign: bFive
      bin op: {'/'}
         nodeType: {'Num'}  value: {'3'}
         var: {'alpha15'}
      var: {'bFive'}
4
   statement assign: pi
      nodeType: {'Num'}  value: {'3.141592'}
      var: {'pi'}
5
   statement assign: aFalse
      comparator op: {'>'}
         nodeType: {'Num'}  value: {'4'}
         nodeType: {'Num'}  value: {'3'}
      var: {'aFalse'}
6
   statement assign: bTrue
      comparator op: {'<'}
         nodeType: {'Num'}  value: {'2'}
         nodeType: {'Num'}  value: {'1'}
      var: {'bTrue'}
7
   statement assign: cTrue
      comparator op: {'>='}
         nodeType: {'Num'}  value: {'5'}
         nodeType: {'Num'}  value: {'5'}
      var: {'cTrue'}
8
   statement assign: dTrue
      comparator op: {'<='}
         nodeType: {'Num'}  value: {'6'}
         nodeType: {'Num'}  value: {'6'}
      var: {'dTrue'}
9
   statement assign: eTrue
      comparator op: {'>'}
         bin op: {'-'}
            nodeType: {'Num'}  value: {'2'}
            nodeType: {'Num'}  value: {'4'}
         bin op: {'*'}
            nodeType: {'Num'}  value: {'3'}
            nodeType: {'Num'}  value: {'2'}
      var: {'eTrue'}
10
   statement assign: shouldBeFalse
      negation: {'!'}
         boolean: {'true'}
      var: {'shouldBeFalse'}
11
   statement assign: under_score_var
      nodeType: {'Num'}  value: {'12'}
      var: {'under_score_var'}
12
   statement assign: false2
      negation: {'!'}
         comparator op: {'>'}
            unary op: {'+'}
               nodeType: {'Num'}  value: {'4'}
            nodeType: {'Num'}  value: {'3'}
      var: {'false2'}
13
   statement assign: modulus_3
      bin op: {'%'}
         nodeType: {'Num'}  value: {'5'}
         nodeType: {'Num'}  value: {'18'}
      var: {'modulus_3'}
14
   statement assign: modulus_2
      bin op: {'%'}
         nodeType: {'Num'}  value: {'3'}
         unary op: {'-'}
            nodeType: {'Num'}  value: {'1'}
      var: {'modulus_2'}
========== global symbol table =============
pi = 3.141592
modulus_2 = 2
bTrue = true
modulus_3 = 3
aFalse = false
cTrue = true
bFive = 5
false2 = true
dTrue = true
alpha15 = 15
shouldBeFalse = false
eTrue = true
under_score_var = 12
boolTrue = true
========ASSERTION CHECKS=======
========ALL CHECKS PASSED=======
[Finished in 0.05s]
```
