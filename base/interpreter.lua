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

function Interpreter:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    parser = o.parser,
    symbol_table_global = {}
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Interpreter:error(msg)
  error(msg)
end

-----------------------------------------------------------------------
-- Public interface
-----------------------------------------------------------------------

function Interpreter:interpret()
  tree = self.parser:parse()

  print("====== PARSE TREE =====")
  tree:display(0)
  print("=======================")

  return self:visit(tree)
end

-----------------------------------------------------------------------
-- AST traversal
-- Every node must have a corresponding method here
-----------------------------------------------------------------------

function Interpreter:visit(node)
  -- See https://stackoverflow.com/questions/26042599/lua-call-a-function-using-its-name-string-in-a-class
  -- tree:display(0)
  -- tree["display"](tree, 0)

  local method_name = "visit_" .. node.type
  if (self[method_name] == nil) then
    self:error("No method in interpreter with name: " .. dq(method_name))
  end

  -- print("visiting " .. method_name)

  -- Call and return the method
  return self[method_name](self, node)
end

function Interpreter:visit_BinOp(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  if node.token.type == Symbols.PLUS then
    return left + right
  elseif node.token.type == Symbols.MINUS then
    return left - right
  elseif node.token.type == Symbols.MUL then
    return left * right
  elseif node.token.type == Symbols.DIV then
    if (right == 0) then
      self:error("Division by Zero")
    end
    return left / right
  end
end

function Interpreter:visit_UnaryOp(node)
  if node.token.type == Symbols.PLUS then
    return self:visit(node.expr)
  elseif node.token.type == Symbols.MINUS then
    return -self:visit(node.expr)
  end
end

function Interpreter:visit_Num(node)
  return tonumber(node.value)
end

function Interpreter:visit_NoOp(node)
  -- do nothing
end

function Interpreter:visit_Assign(node)
  local variable_name = node.left.value
  self.symbol_table_global[variable_name] = self:visit(node.right)
end

function Interpreter:visit_Bool(node)
  local boolean = node.value
  return boolean == "true"
end

function Interpreter:visit_Var(node)
  local variable_name = node.value

  -- Check if this variable has been defined already
  if (self.symbol_table_global[variable_name] == nil) then
    self:error("Undefined variable " .. variable_name)
  else
    return self.symbol_table_global[variable_name]
  end
end

function Interpreter:visit_Cmp(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  if node.token.type == Symbols.CMP_EQUALS then
    return left == right
  elseif node.token.type == Symbols.CMP_NEQUALS then
    return left ~= right
  elseif node.token.type == Symbols.GT then
    return left > right
  elseif node.token.type == Symbols.LT then
    return left < right
  elseif node.token.type == Symbols.GTE then
    return left >= right
  elseif node.token.type == Symbols.LTE then
    return left <= right
  end
end

function Interpreter:visit_Negate(node)
  -- print(node.token.type)
  -- if node.token.type == Symbols.NEGATE then
    return not self:visit(node.expr)
  -- end
end

function Interpreter:visit_Program(node)
  -- Iterate over each of the children
  for key,childNode in ipairs(node.children) do
    self:visit(childNode)
  end
end
