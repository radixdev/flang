--[[

Interpreter for the Flang language ;)

"Uses" the visitor pattern to evaluate the AST from the parser.

]]

Interpreter = {}
Flang.Interpreter = Interpreter
Interpreter.__index = Interpreter

function Interpreter:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    parser = o.parser,
    symbol_table_global = {},
    tree = o.parser:parse()
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
  if (Flang.DEBUG_LOGGING) then
    print("====== PARSE TREE =====")
    self.tree:display(0)
    print("====== END TREE =======\n")
  end

  return self:visit(self.tree)
end

-----------------------------------------------------------------------
-- State information
-----------------------------------------------------------------------

function Interpreter:get_variable(variable_name)
  -- Check if this variable has been defined already
  if (self.symbol_table_global[variable_name] == nil) then
    self:error("Undefined variable " .. variable_name)
  else
    return self.symbol_table_global[variable_name]
  end
end

function Interpreter:set_variable(variable_name, value)
  self.symbol_table_global[variable_name] = value
end

-----------------------------------------------------------------------
-- AST traversal
-- Every node must have a corresponding method here
-----------------------------------------------------------------------

function Interpreter:visit(node)
  -- See https://stackoverflow.com/questions/26042599/lua-call-a-function-using-its-name-string-in-a-class

  -- comment out for faster performance
  local method_name = node.type
  if not self[method_name] then
    self:error("No method in interpreter with name: " .. dq(node.type))
  end

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
  local token_type = node.assignment_token.type

  if (token_type == Symbols.EQUALS) then
    self:set_variable(variable_name, self:visit(node.right))
    return
  end

  -- We have to make sure
  if (token_type == Symbols.ASSIGN_PLUS) then
    -- self.symbol_table_global[variable_name] = self:get_variable(variable_name) + self:visit(node.right)
    self:set_variable(variable_name, self:get_variable(variable_name) + self:visit(node.right))
  elseif (token_type == Symbols.ASSIGN_MINUS) then
    -- self.symbol_table_global[variable_name] = self:get_variable(variable_name) - self:visit(node.right)
    self:set_variable(variable_name, self:get_variable(variable_name) - self:visit(node.right))

  elseif (token_type == Symbols.ASSIGN_MUL) then
    -- self.symbol_table_global[variable_name] = self:get_variable(variable_name) * self:visit(node.right)
    self:set_variable(variable_name, self:get_variable(variable_name) * self:visit(node.right))

  elseif (token_type == Symbols.ASSIGN_DIV) then
    local right_value = self:visit(node.right)
    if (right_value == 0) then
      self:error("Division by Zero")
    end
    -- self.symbol_table_global[variable_name] = self:get_variable(variable_name) / right_value
    self:set_variable(variable_name, self:get_variable(variable_name) / self:visit(node.right))
  end
end

function Interpreter:Bool(node)
  return node.parsed_value
end

function Interpreter:Var(node)
  return self:get_variable(node.value)
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
  --[[
    This is either a standard for loop or an enhanced for loop.

    Enhanced for-loops have the following structure:
    for (assignment ; number (; number) ) block

    Without this structure, we fallback to the standard for loop
  ]]

  self:visit(node.initializer)

  if (node.enhanced) then
    -- extract the variable
    local variable_name = node.initializer.left.value

    -- visit the condition value
    local condition_value = self:visit(node.condition)
    if (type(condition_value) ~= "number") then
      self:error("Expected for loop condition to evaluate to number")
    end

    local initializer_value = self:get_variable(variable_name)

    if (node.incrementer.type == Node.NO_OP_TYPE) then
      incrementer_value = 1
    else
      incrementer_value = self:visit(node.incrementer)
    end

    for i = initializer_value, (condition_value-1), incrementer_value do
      self:visit(node.block)
      -- set i
      self:set_variable(variable_name, i)
    end
  else
    self:visit(node.initializer)

    while self:visit(node.condition) do
      self:visit(node.block)
      self:visit(node.incrementer)
    end
  end
end
