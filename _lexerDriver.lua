require("base.character")
require("base.lexer")
require("base.symbols")

-- load our file
filename = "samples/b1.flang"
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

print("===============")
print(t)
print("===============")

-- give it to the lexer
lexer = Flang.Lexer:new({sourceText = t})

while true do
  token = lexer:get()
  print(tostring(token))

  if (token.type == Symbols.EOF) then
    break
  end
end
