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
  local tree = self.parser:parse()

  if (Flang.DEBUG_LOGGING) then
    print("====== PARSE TREE =====")
    tree:display(0)
    print("=======================")
  end

  return self:visit(tree)
end

-----------------------------------------------------------------------
-- AST traversal
-- Every node must have a corresponding method here
-----------------------------------------------------------------------

function Interpreter:visit(node)
  -- See https://stackoverflow.com/questions/26042599/lua-call-a-function-using-its-name-string-in-a-class

  -- comment out for faster performance
  -- if not self[node.type] then
  --   self:error("No method in interpreter with name: " .. dq(node.type))
  -- end

  -- print("visiting " .. method_name)

  -- Call and return the method
  return self[node.type](self, node)
end

function Interpreter:BinOp(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  if node.token_type == Symbols.PLUS then
    return left + right
  elseif node.token_type == Symbols.MINUS then
    return left - right
  elseif node.token_type == Symbols.MUL then
    return left * right
  elseif node.token_type == Symbols.DIV then
    if (right == 0) then
      self:error("Division by Zero")
    end
    return left / right
  elseif node.token_type == Symbols.MODULUS then
    return left % right
  end
end

function Interpreter:UnaryOp(node)
  if node.token_type == Symbols.PLUS then
    return self:visit(node.expr)
  elseif node.token_type == Symbols.MINUS then
    return -self:visit(node.expr)
  end
end

function Interpreter:Num(node)
  return node.parsed_value
end

function Interpreter:NoOp(node)
  -- do nothing
end

function Interpreter:Assign(node)
  local variable_name = node.left.value
  self.symbol_table_global[variable_name] = self:visit(node.right)
end

function Interpreter:Bool(node)
  return node.parsed_value
end

function Interpreter:Var(node)
  local variable_name = node.value

  -- Check if this variable has been defined already
  if (self.symbol_table_global[variable_name] == nil) then
    self:error("Undefined variable " .. variable_name)
  else
    return self.symbol_table_global[variable_name]
  end
end

function Interpreter:Cmp(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  if node.token_type == Symbols.CMP_EQUALS then
    return left == right
  elseif node.token_type == Symbols.CMP_NEQUALS then
    return left ~= right
  elseif node.token_type == Symbols.GT then
    return left > right
  elseif node.token_type == Symbols.LT then
    return left < right
  elseif node.token_type == Symbols.GTE then
    return left >= right
  elseif node.token_type == Symbols.LTE then
    return left <= right
  end
end

function Interpreter:Negate(node)
  return not self:visit(node.expr)
end

function Interpreter:If(node)
  --[[
    Only execute the block if:
      ("if" or "elseif") the conditional exists and is true
      ("else") no conditional exists
  ]]
  local should_execute_block = true

  if node.conditional then
    should_execute_block = self:visit(node.conditional)
  end

  -- If this block gets executed, then any subsequent blocks do not get executed
  if should_execute_block then
    self:visit(node.block)
  else
    if node.next_if then
      self:visit(node.next_if)
    end
  end
end

function Interpreter:StatementList(node)
  -- Iterate over each of the children
  -- for _,childNode in ipairs(node.children) do
  --   self:visit(childNode)
  -- end

  -- faster than ipairs
  local k
  for k=1, node.num_children-1 do
    local childNode = node.children[k]
    self:visit(childNode)
  end
end

function Interpreter:For(node)
  self:visit(node.initializer)

  while self:visit(node.condition) do
    self:visit(node.block)
    self:visit(node.incrementer)
  end
end
