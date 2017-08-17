require("base.lexer")
require("base.parser")
require("base.interpreter")

filename = "samples/wacky.flang"
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

print("===============")
print(t)
print("===============")

local start_time = os.clock()
lexer = Flang.Lexer:new({sourceText = t})
parser = Flang.Parser:new({lexer = lexer})
interpreter = Flang.Interpreter:new({parser = parser})
result = interpreter:interpret()
local elapsed = os.clock() - start_time

-- print out the symbol table
print("===============")
print("global symbol table")
symbol_table = interpreter.symbol_table_global
for key,value in pairs(symbol_table) do
  print(key .. " = " .. tostring(value))
end

print(string.format("elapsed time: %.2f\n", os.clock() - start_time))
