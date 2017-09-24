require("base.scanner")
require("base.character")

-- load our file
filename = "samples/1.flang"
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

print(t)

-- give it to the scanner
scanner = Flang.Scanner:new({sourceText = t})

while true do
  char = scanner:get()
  print(tostring(char))
  
  if (char.cargo == Flang.Character.ENDMARK) then
    break
  end
end
