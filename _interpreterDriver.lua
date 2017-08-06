require("base.lexer")
require("base.parser")
require("base.interpreter")

filename = "samples/s2.flang"
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

print("===============")
print(t)
print("===============")

-- give it to the lexer
lexer = Flang.Lexer:new({sourceText = t})

-- then to the parser!
parser = Flang.Parser:new({lexer = lexer})

-- and now the interpreter
interpreter = Flang.Interpreter:new({parser = parser})

result = interpreter:interpret()

-- print out the symbol table
print("global symbol table")
symbol_table = interpreter.symbol_table_global
for key,value in pairs(symbol_table) do
  print(key .. " = " .. value)
end
