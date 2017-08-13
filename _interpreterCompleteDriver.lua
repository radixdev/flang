require("base.lexer")
require("base.parser")
require("base.interpreter")

filename = "samples/complete.flang"
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
print("global symbol table")
symbol_table = interpreter.symbol_table_global
for key,value in pairs(symbol_table) do
  print(key .. " = " .. tostring(value))
end

function assertEquals(var, expected)
  local actual = symbol_table[var]
  if actual ~= expected then
    print("Assertion error on "..dq(var))
    print("Expected "..dq(expected).." but got "..dq(actual))
    error("AssertionFailure")
  end
end

print("========ASSERTION CHECKS=======")
assertEquals("pi", 3.141592)
assertEquals("bTrue", true)
assertEquals("aFalse", false)
assertEquals("cTrue", true)
assertEquals("bFive", 5)
assertEquals("false2", true)
assertEquals("dTrue", true)
assertEquals("alpha15", 15)
assertEquals("shouldBeFalse", false)
assertEquals("eTrue", true)
assertEquals("under_score_var", 12)
assertEquals("boolTrue", true)

assertEquals("modulus_2", 2)
assertEquals("modulus_3", 3)

assertEquals("ifShouldBe6", 6)
assertEquals("ifShouldBe10", 10)
assertEquals("ifShouldBe7", 7)

assertEquals("forShouldBe100", 100)
print("========ALL CHECKS PASSED=======")
print(string.format("elapsed time: %.2f\n", os.clock() - start_time))
