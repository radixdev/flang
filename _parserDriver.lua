require("base.lexer")
require("base.parser")

filename = "samples/s1.flang"
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

tree = parser:parse()

print("===============")
tree:display()
print("===============")
