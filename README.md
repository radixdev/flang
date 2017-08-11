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
[Command: lua /Users/juliancontreras/code_mobile/radixdev/flang/_interpreterCompleteDriver.lua]
===============
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

if (3 < 1) {
  ifShouldBe6 = 2
} elseif (1 > 6) {

} elseif (4 == 4) {
  ifShouldBe6 = 6
}

if (true) {
  if (true) {
    if (false) {

    } else {
      ifShouldBe10 = 10
    }
  }
}

===============
creating program node
creating var node {line: '0'	 column: '0'	 type 'Identifier'	'alpha15'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '0'	 column: '10'	 type 'Number'		'15'}
creating assign node: {'nodeType: {'Var'}  value: {'alpha15'}'} and token {'alpha15'}
creating var node {line: '1'	 column: '1'	 type 'Identifier'	'boolTrue'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'true'}
creating boolean node {line: '1'	 column: '12'	 type 'true'		'true'}
creating assign node: {'nodeType: {'Var'}  value: {'boolTrue'}'} and token {'boolTrue'}
creating var node {line: '3'	 column: '1'	 type 'Identifier'	'bFive'}
  Ate token {'Identifier'}
  Ate token {'='}
creating var node {line: '3'	 column: '9'	 type 'Identifier'	'alpha15'}
  Ate token {'Identifier'}
  Ate token {'/'}
  Ate token {'Number'}
creating num node {line: '3'	 column: '19'	 type 'Number'		'3'}
creating bin op node {line: '3'	 column: '17'	 type '/'		'/'}
creating assign node: {'nodeType: {'Var'}  value: {'bFive'}'} and token {'bFive'}
creating var node {line: '5'	 column: '1'	 type 'Identifier'	'pi'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '5'	 column: '6'	 type 'Number'		'3.141592'}
creating assign node: {'nodeType: {'Var'}  value: {'pi'}'} and token {'pi'}
creating var node {line: '7'	 column: '1'	 type 'Identifier'	'aFalse'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '7'	 column: '10'	 type 'Number'		'3'}
  Ate token {'>'}
  Ate token {'Number'}
creating num node {line: '7'	 column: '14'	 type 'Number'		'4'}
creating comparator node: {'{line: '7'	 column: '12'	 type '>'		'>'}'}
creating assign node: {'nodeType: {'Var'}  value: {'aFalse'}'} and token {'aFalse'}
creating var node {line: '8'	 column: '1'	 type 'Identifier'	'bTrue'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '8'	 column: '9'	 type 'Number'		'1'}
  Ate token {'<'}
  Ate token {'Number'}
creating num node {line: '8'	 column: '13'	 type 'Number'		'2'}
creating comparator node: {'{line: '8'	 column: '11'	 type '<'		'<'}'}
creating assign node: {'nodeType: {'Var'}  value: {'bTrue'}'} and token {'bTrue'}
creating var node {line: '9'	 column: '1'	 type 'Identifier'	'cTrue'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '9'	 column: '9'	 type 'Number'		'5'}
  Ate token {'>='}
  Ate token {'Number'}
creating num node {line: '9'	 column: '14'	 type 'Number'		'5'}
creating comparator node: {'{line: '9'	 column: '11'	 type '>='		'>='}'}
creating assign node: {'nodeType: {'Var'}  value: {'cTrue'}'} and token {'cTrue'}
creating var node {line: '10'	 column: '1'	 type 'Identifier'	'dTrue'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '10'	 column: '9'	 type 'Number'		'6'}
  Ate token {'<='}
  Ate token {'Number'}
creating num node {line: '10'	 column: '14'	 type 'Number'		'6'}
creating comparator node: {'{line: '10'	 column: '11'	 type '<='		'<='}'}
creating assign node: {'nodeType: {'Var'}  value: {'dTrue'}'} and token {'dTrue'}
creating var node {line: '12'	 column: '1'	 type 'Identifier'	'eTrue'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '12'	 column: '9'	 type 'Number'		'2'}
  Ate token {'*'}
  Ate token {'Number'}
creating num node {line: '12'	 column: '12'	 type 'Number'		'3'}
creating bin op node {line: '12'	 column: '11'	 type '*'		'*'}
  Ate token {'>'}
  Ate token {'Number'}
creating num node {line: '12'	 column: '16'	 type 'Number'		'4'}
  Ate token {'-'}
  Ate token {'Number'}
creating num node {line: '12'	 column: '20'	 type 'Number'		'2'}
creating bin op node {line: '12'	 column: '18'	 type '-'		'-'}
creating comparator node: {'{line: '12'	 column: '14'	 type '>'		'>'}'}
creating assign node: {'nodeType: {'Var'}  value: {'eTrue'}'} and token {'eTrue'}
creating var node {line: '14'	 column: '1'	 type 'Identifier'	'shouldBeFalse'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'!'}
  Ate token {'true'}
creating boolean node {line: '14'	 column: '16'	 type 'true'		'true'}
creating negation node {line: '14'	 column: '15'	 type '!'		'!'}
creating assign node: {'nodeType: {'Var'}  value: {'shouldBeFalse'}'} and token {'shouldBeFalse'}
creating var node {line: '16'	 column: '1'	 type 'Identifier'	'under_score_var'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '16'	 column: '19'	 type 'Number'		'12'}
creating assign node: {'nodeType: {'Var'}  value: {'under_score_var'}'} and token {'under_score_var'}
creating var node {line: '17'	 column: '1'	 type 'Identifier'	'false2'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'!'}
  Ate token {'('}
  Ate token {'Number'}
creating num node {line: '17'	 column: '13'	 type 'Number'		'3'}
  Ate token {'>'}
  Ate token {'+'}
  Ate token {'Number'}
creating num node {line: '17'	 column: '16'	 type 'Number'		'4'}
creating unary op node {line: '17'	 column: '15'	 type '+'		'+'}
creating comparator node: {'{line: '17'	 column: '14'	 type '>'		'>'}'}
  Ate token {')'}
creating negation node {line: '17'	 column: '10'	 type '!'		'!'}
creating assign node: {'nodeType: {'Var'}  value: {'false2'}'} and token {'false2'}
creating var node {line: '19'	 column: '1'	 type 'Identifier'	'modulus_3'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '19'	 column: '13'	 type 'Number'		'18'}
  Ate token {'%'}
  Ate token {'Number'}
creating num node {line: '19'	 column: '18'	 type 'Number'		'5'}
creating bin op node {line: '19'	 column: '16'	 type '%'		'%'}
creating assign node: {'nodeType: {'Var'}  value: {'modulus_3'}'} and token {'modulus_3'}
creating var node {line: '20'	 column: '1'	 type 'Identifier'	'modulus_2'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'-'}
  Ate token {'Number'}
creating num node {line: '20'	 column: '14'	 type 'Number'		'1'}
creating unary op node {line: '20'	 column: '13'	 type '-'		'-'}
  Ate token {'%'}
  Ate token {'Number'}
creating num node {line: '20'	 column: '18'	 type 'Number'		'3'}
creating bin op node {line: '20'	 column: '16'	 type '%'		'%'}
creating assign node: {'nodeType: {'Var'}  value: {'modulus_2'}'} and token {'modulus_2'}
  Ate token {'if'}
  Ate token {'('}
  Ate token {'Number'}
creating num node {line: '22'	 column: '5'	 type 'Number'		'3'}
  Ate token {'<'}
  Ate token {'Number'}
creating num node {line: '22'	 column: '9'	 type 'Number'		'1'}
creating comparator node: {'{line: '22'	 column: '7'	 type '<'		'<'}'}
  Ate token {')'}
  Ate token {'{'}
creating var node {line: '23'	 column: '3'	 type 'Identifier'	'ifShouldBe6'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '23'	 column: '17'	 type 'Number'		'2'}
creating assign node: {'nodeType: {'Var'}  value: {'ifShouldBe6'}'} and token {'ifShouldBe6'}
  Ate token {'}'}
  Ate token {'elseif'}
  Ate token {'('}
  Ate token {'Number'}
creating num node {line: '24'	 column: '11'	 type 'Number'		'1'}
  Ate token {'>'}
  Ate token {'Number'}
creating num node {line: '24'	 column: '15'	 type 'Number'		'6'}
creating comparator node: {'{line: '24'	 column: '13'	 type '>'		'>'}'}
  Ate token {')'}
  Ate token {'{'}
creating no-op node
  Ate token {'}'}
  Ate token {'elseif'}
  Ate token {'('}
  Ate token {'Number'}
creating num node {line: '26'	 column: '11'	 type 'Number'		'4'}
  Ate token {'=='}
  Ate token {'Number'}
creating num node {line: '26'	 column: '16'	 type 'Number'		'4'}
creating comparator node: {'{line: '26'	 column: '13'	 type '=='		'=='}'}
  Ate token {')'}
  Ate token {'{'}
creating var node {line: '27'	 column: '3'	 type 'Identifier'	'ifShouldBe6'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '27'	 column: '17'	 type 'Number'		'6'}
creating assign node: {'nodeType: {'Var'}  value: {'ifShouldBe6'}'} and token {'ifShouldBe6'}
  Ate token {'}'}
creating if node {line: '26'	 column: '3'	 type 'elseif'		'elseif'}
creating if node {line: '24'	 column: '3'	 type 'elseif'		'elseif'}
creating if node {line: '22'	 column: '1'	 type 'if'		'if'}
  Ate token {'if'}
  Ate token {'('}
  Ate token {'true'}
creating boolean node {line: '30'	 column: '5'	 type 'true'		'true'}
  Ate token {')'}
  Ate token {'{'}
  Ate token {'if'}
  Ate token {'('}
  Ate token {'true'}
creating boolean node {line: '31'	 column: '7'	 type 'true'		'true'}
  Ate token {')'}
  Ate token {'{'}
  Ate token {'if'}
  Ate token {'('}
  Ate token {'false'}
creating boolean node {line: '32'	 column: '9'	 type 'false'		'false'}
  Ate token {')'}
  Ate token {'{'}
creating no-op node
  Ate token {'}'}
  Ate token {'else'}
  Ate token {'{'}
creating var node {line: '35'	 column: '7'	 type 'Identifier'	'ifShouldBe10'}
  Ate token {'Identifier'}
  Ate token {'='}
  Ate token {'Number'}
creating num node {line: '35'	 column: '22'	 type 'Number'		'10'}
creating assign node: {'nodeType: {'Var'}  value: {'ifShouldBe10'}'} and token {'ifShouldBe10'}
  Ate token {'}'}
creating if node {line: '34'	 column: '7'	 type 'else'		'else'}
creating if node {line: '32'	 column: '5'	 type 'if'		'if'}
  Ate token {'}'}
creating if node {line: '31'	 column: '3'	 type 'if'		'if'}
  Ate token {'}'}
creating if node {line: '30'	 column: '1'	 type 'if'		'if'}
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
15
  if: {'if'}
    CONDITIONAL: comparator op: {'<'}
      nodeType: {'Num'}  value: {'1'}
      nodeType: {'Num'}  value: {'3'}
    BLOCK: statement assign: ifShouldBe6
      nodeType: {'Num'}  value: {'2'}
      var: {'ifShouldBe6'}
      if: {'elseif'}
        CONDITIONAL: comparator op: {'>'}
          nodeType: {'Num'}  value: {'6'}
          nodeType: {'Num'}  value: {'1'}
        BLOCK: no op
          if: {'elseif'}
            CONDITIONAL: comparator op: {'=='}
              nodeType: {'Num'}  value: {'4'}
              nodeType: {'Num'}  value: {'4'}
            BLOCK: statement assign: ifShouldBe6
              nodeType: {'Num'}  value: {'6'}
              var: {'ifShouldBe6'}
16
  if: {'if'}
    CONDITIONAL: boolean: {'true'}
    BLOCK: if: {'if'}
      CONDITIONAL: boolean: {'true'}
      BLOCK: if: {'if'}
        CONDITIONAL: boolean: {'false'}
        BLOCK: no op
          if: {'else'}
            BLOCK: statement assign: ifShouldBe10
              nodeType: {'Num'}  value: {'10'}
              var: {'ifShouldBe10'}
=======================
global symbol table
bTrue = true
cTrue = true
under_score_var = 12
false2 = true
shouldBeFalse = false
modulus_2 = 2
dTrue = true
eTrue = true
bFive = 5
ifShouldBe6 = 6
aFalse = false
alpha15 = 15
boolTrue = true
ifShouldBe10 = 10
modulus_3 = 3
pi = 3.141592
========ASSERTION CHECKS=======
========ALL CHECKS PASSED=======
elapsed time: 0.00

[Finished in 0.043s]
```
