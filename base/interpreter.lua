--[[

Interpreter for the Flang language ;)

"Uses" the visitor pattern to evaluate the AST from the parser.

]]

require("base.parser")
require("base.util")

if not Flang then Flang = {} end
Interpreter = {}
Flang.Interpreter = Interpreter
Interpreter.__index = Interpreter

--[[

]]
function Interpreter:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    parser = o.parser
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Interpreter:interpret()
  tree = self.parser:parse()

  print("====== PARSE TREE =====")
  tree:display(0)
  print("=======================")
end

function Interpreter:visit(node)
  -- See https://stackoverflow.com/questions/26042599/lua-call-a-function-using-its-name-string-in-a-class
  -- tree:display(0)
  -- tree["display"](tree, 0)
end

function Interpreter:visit_BinOp(node)

end
