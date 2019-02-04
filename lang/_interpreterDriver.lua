require("base.flang_import")

filename = "samples/func2.flang"
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

print("===== SOURCE =======")
print(t)
print("==== END SOURCE ====\n")

Flang.DEBUG_LOGGING = true
Flang.VERBOSE_LOGGING = false

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

print(string.format("elapsed time: %.5fs or %.2fms\n", elapsed, elapsed * 1000))
