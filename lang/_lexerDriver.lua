require("base.flang_import")

-- load our file
filename = "samples/comment1.flang"
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
