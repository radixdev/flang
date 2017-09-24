# flang
Factorio Interpreter in Lua

# description

The EBNF language definition can be found in `base\parser.lua`.

The flow from source file to symbol table is as follows:

[source file] -> [characters] -> `base\scanner.lua` -> `base\lexer.lua` -> [tokens] -> `base\parser.lua` -> [nodes] -> `base\interpreter.lua` -> [symbol table]

## symbol table

The symbol table is a mapping between variable names and values.

# drivers
The drivers run different functionality modules of the language. For example, the `_lexerDriver.lua` will run the lexer and print tokens of the source input file.

# example

A complete example of Flang can be found in the `samples/complete.flang` file. Running `lua _interpreterCompleteDriver.lua` will run this example and assertions. An example successful output (with lexer tokens) is printed below:
