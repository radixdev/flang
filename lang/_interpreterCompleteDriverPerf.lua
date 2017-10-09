require("base.flang_import")

Flang.DEBUG_LOGGING = false

filename = "samples/complete.flang"
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

lexer = Flang.Lexer:new({sourceText = t})
parser = Flang.Parser:new({lexer = lexer})
interpreter = Flang.Interpreter:new({parser = parser})
local start_time = os.clock()

for i=0, 100 do
  result = interpreter:interpret()
end
local elapsed = os.clock() - start_time

print(string.format("elapsed time: %.5f", elapsed))
print(string.format("elapsed time per execution: %.5f", elapsed / 100.0000))
