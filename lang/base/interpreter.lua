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
    -- The wrapper contains info from the runner.
    wrapper = o.wrapper or {},
    symbol_table_global = {},
    method_table_global = {},

    current_symbol_scope = nil,
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

  self.current_symbol_scope = Flang.Scope:new({})
  return self:visit(self.tree)
end

-----------------------------------------------------------------------
-- State information
-----------------------------------------------------------------------

function Interpreter:get_variable(variable_name)
  -- Check if this variable has been defined already
  return self.current_symbol_scope:getVariable(variable_name)
end

function Interpreter:set_variable(variable_name, value)
  self.current_symbol_scope:setVariable(variable_name, value)
end

function Interpreter:add_method_definition(method_name, arguments, num_arguments, block)
  --[[
    Adds a method to the global namespace

    By default, methods are defined on the current class, "this"
    Methods defined in other classes are prefixed with their class.

    "bar()" is just named as "bar"
    "Foo.baz()" is named as "Foo.baz"
  ]]

  if (method_name == nil) then
    self:error("Cannot define nil method name")
  end

  -- We'll construct this method using the above info, and add it to the
  -- global methods table at the end
  local method = {
    method_name = method_name,
    arguments = arguments,
    num_arguments = num_arguments,
    block = block
  }

  self.method_table_global[method_name] = method
end

--[[
  returns ->
    {
      method_name = method_name,
      arguments = arguments,
      block = block
    }
]]
function Interpreter:get_method(method_name)
  if (method_name == nil) then
    self:error("Cannot get method with nil name")
  end

  if (self.method_table_global[method_name] == nil) then
    self:error("Method lookup failed for name " .. method_name)
  end

  return self.method_table_global[method_name]
end

function Interpreter:get_function_method(function_class, method_name)
  -- hail mary of a call
  if (Flang.LuaFunction[function_class] == nil) then
    print(function_class)
    self:error("Function class lookup failed for name <" .. function_class .. ">")
  end

  if (Flang.LuaFunction[function_class][method_name] == nil) then
    self:error("Function class method lookup failed for name <" .. function_class .. "." .. method_name .. ">")
  end

  return Flang.LuaFunction[function_class][method_name]
end

-----------------------------------------------------------------------
-- AST traversal
-- Every node must have a corresponding method here
-----------------------------------------------------------------------

function Interpreter:visit(node)
  -- See https://stackoverflow.com/questions/26042599/lua-call-a-function-using-its-name-string-in-a-class

  -- comment out this logging for faster performance
  local method_name = node.type
  if not self[method_name] then
    self:error("No method in interpreter with name: " .. dq(node.type))
  end
  -- end section

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

function Interpreter:String(node)
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
    self:set_variable(variable_name, self:get_variable(variable_name) + self:visit(node.right))

  elseif (token_type == Symbols.ASSIGN_MINUS) then
    self:set_variable(variable_name, self:get_variable(variable_name) - self:visit(node.right))

  elseif (token_type == Symbols.ASSIGN_MUL) then
    self:set_variable(variable_name, self:get_variable(variable_name) * self:visit(node.right))

  elseif (token_type == Symbols.ASSIGN_DIV) then
    local right_value = self:visit(node.right)
    if (right_value == 0) then
      self:error("Division by Zero")
    end
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
  -- Note, this is faster than ipairs
  local k
  for k=1, node.num_children-1 do
    local childNode = node.children[k]
    -- Check for the return type
    if (childNode.type == Node.RETURN_STATEMENT_TYPE) then
      return self:visit(childNode)
    else
      self:visit(childNode)
    end
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

function Interpreter:MethodDefinition(node)
  -- So there's a method name, the executable block, and the argument list
  self:add_method_definition(node.method_name, node.arguments, node.num_arguments, node.block)
end

function Interpreter:MethodInvocation(node)
  -- TODO I assume here is where we'd declare our block scoping and all that

  -- Get the method
  local method = self:get_method(node.method_name)

  -- Translate our arguments
  local method_arguments = method.arguments
  local invocation_arguments = node.arguments

  if (method.num_arguments ~= node.num_arguments) then
    self:error("Expected " .. method.num_arguments  .. " arguments for method <" .. node.method_name .. "> but instead got " .. node.num_arguments)
  end

  local k
  for k = 1, node.num_arguments do
    -- This is a Node.METHOD_ARGUMENT_TYPE
    local method_arg = method_arguments[k]

    -- This is some expression that needs to be visited for evaluation
    local invocation_arg = invocation_arguments[k]

    self:set_variable(method_arg.value, self:visit(invocation_arg))
  end

  -- Execute the block
  return self:visit(method.block)
end

function Interpreter:ReturnStatement(node)
  return self:visit(node.expr)
end

function Interpreter:FunctionCall(node)
  -- Get the function method
  -- note that this doesn't do chaining
  local method_invocation = node.method_invocation
  local functionMethod = self:get_function_method(node.class, method_invocation.method_name)

  -- Each argument needs to be visited first!
  local k
  local visitedArguments = {}
  for k = 1, method_invocation.num_arguments do
    -- This is some expression that needs to be visited for evaluation
    local invocation_arg = method_invocation.arguments[k]

    visitedArguments[k] = self:visit(invocation_arg)
  end

  local functionReturnValue = functionMethod(self, self.wrapper, visitedArguments)
  return functionReturnValue.result
end
