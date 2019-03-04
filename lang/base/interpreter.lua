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
    method_table_global = {},

    current_symbol_scope = nil,

    global_symbol_scope = nil,
    tree = o.parser:parse()
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Interpreter:error(msg)
  if (lastVisitedNode and lastVisitedNode.token and Util.isTable(lastVisitedNode.token)) then
    local errorMsg = msg .. "\nat " .. Util.set_to_string_dumb(lastVisitedNode.token)
    local source = self.parser.lexer.sourceText
    local errorLine = lastVisitedNode.token.lineIndex

    -- Print the line itself
    local lineNum = 0
    for line in source:gmatch("([^\n]*)\n?") do
      lineNum = lineNum + 1
      if (lineNum == errorLine) then
        errorMsg = errorMsg .. "\n>    " .. line
        break
      end
    end

    error(errorMsg)
  else
    error(msg)
  end
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

lastVisitedNode = nil
function Interpreter:visit(node)
  if (node == nil) then
    self:error("Interpreter got nil node!")
  end

  -- See https://stackoverflow.com/questions/26042599/lua-call-a-function-using-its-name-string-in-a-class

  -- comment out this logging for faster performance
  local method_name = node.type
  if not self[method_name] then
    self:error("No method in interpreter with name: " .. dq(node.type))
  end
  -- end section

  lastVisitedNode = node
  -- print("visiting " .. method_name)

  -- Call and return the method
  return self[node.type](self, node)
end

function Interpreter:BinOp(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  if node.token_type == Symbols.PLUS then
    if (Util.isString(left) or Util.isString(right)) then
      return tostring(left) .. tostring(right)
    else
      return left + right
    end
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

function Interpreter:LogicalOr(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  return left or right
end

function Interpreter:LogicalAnd(node)
  local left = self:visit(node.left)
  local right = self:visit(node.right)

  return left and right
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

  local visitedRightNode = self:visit(node.right)
  if (token_type == Symbols.EQUALS) then
    self:set_variable(variable_name, visitedRightNode)
    return
  end

  if (token_type == Symbols.ASSIGN_PLUS) then
    local assignValue
    local visitedLeftNode = self:get_variable(variable_name)
    if (Util.isString(visitedLeftNode) and Util.isString(visitedRightNode)) then
      assignValue = visitedLeftNode .. visitedRightNode
    else
      assignValue = visitedLeftNode + visitedRightNode
    end
    self:set_variable(variable_name, assignValue)

  elseif (token_type == Symbols.ASSIGN_MINUS) then
    self:set_variable(variable_name, self:get_variable(variable_name) - visitedRightNode)

  elseif (token_type == Symbols.ASSIGN_MUL) then
    self:set_variable(variable_name, self:get_variable(variable_name) * visitedRightNode)

  elseif (token_type == Symbols.ASSIGN_DIV) then
    local right_value = visitedRightNode
    if (right_value == 0) then
      self:error("Division by Zero")
    end
    self:set_variable(variable_name, self:get_variable(variable_name) / visitedRightNode)
  end
end

function Interpreter:ArrayAssign(node)
  local variable_name = node.left.value
  local token_type = node.assignment_token.type

  -- There's a table out there with our variable_name, go get it
  local arrayValue = self:get_variable(variable_name)
  if (not Util.isTable(arrayValue)) then
    self:error("Expected a table. Got something else")
  end

  -- The "+1" is to enable 0 indexing in Flang
  local indexValue = self:visit(node.indexExpr)
  if (Util.isNumber(indexValue)) then
    -- The +1 is to allow 0 indexing
    indexValue = indexValue + 1
  end
  local rightExprValue = self:visit(node.right)

  if (token_type == Symbols.EQUALS) then
    arrayValue[indexValue] = rightExprValue
    return
  end

  -- Everything in the array has already been visited!
  local existingValueAtIndex = arrayValue[indexValue]

  if (token_type == Symbols.ASSIGN_PLUS) then
    arrayValue[indexValue] = existingValueAtIndex + rightExprValue

  elseif (token_type == Symbols.ASSIGN_MINUS) then
    arrayValue[indexValue] = existingValueAtIndex - rightExprValue

  elseif (token_type == Symbols.ASSIGN_MUL) then
    arrayValue[indexValue] = existingValueAtIndex * rightExprValue

  elseif (token_type == Symbols.ASSIGN_DIV) then
    if (rightExprValue == 0) then
      self:error("Division by Zero")
    end
    arrayValue[indexValue] = existingValueAtIndex / rightExprValue
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
    return self:visit(node.block)
  else
    if node.next_if then
      return self:visit(node.next_if)
    end
  end
end

function Interpreter:StatementList(node)
  -- Our block is starting now. Change scope
  self.current_symbol_scope = self.current_symbol_scope:enterBlock()

  if (self.global_symbol_scope == nil) then
    -- This is the first scope ever created. Must be PROGRAM global
    self.global_symbol_scope = self.current_symbol_scope
  end

  -- Iterate over each of the children
  -- Note, this is faster than ipairs
  local k
  for k=1, node.num_children-1 do
    local childNode = node.children[k]

    -- If there's a return value, return it. Else keep going.
    local returnValue = self:visit(childNode)
    if (returnValue ~= nil) then
      self.current_symbol_scope = self.current_symbol_scope:exitBlock()
      return returnValue
    end
  end

  -- Scope has finished. Our block has exited.
  self.current_symbol_scope = self.current_symbol_scope:exitBlock()
end

function Interpreter:MethodDefinition(node)
  -- So there's a method name, the executable block, and the argument list
  self:add_method_definition(node.method_name, node.arguments, node.num_arguments, node.block)
end

function Interpreter:MethodInvocation(node)
  -- Get the method
  local method = self:get_method(node.method_name)

  -- Translate our arguments
  local method_arguments = method.arguments
  local invocation_arguments = node.arguments

  if (method.num_arguments ~= node.num_arguments) then
    self:error("Expected " .. method.num_arguments  .. " arguments for method <"
    .. node.method_name .. "> but instead got " .. node.num_arguments)
  end

  -- Get the proper values for the arguments in the current scope
  -- THEN change scope and set them!

  local argumentValues = {}
  local k
  for k = 1, node.num_arguments do
    -- This is some expression that needs to be visited for evaluation
    local invocation_arg = invocation_arguments[k]
    argumentValues[k] = self:visit(invocation_arg)
  end

  -- Now set the arguments in the invocation scope
  self.current_symbol_scope = self.current_symbol_scope:enterCall()

  for k = 1, node.num_arguments do
    -- This is a Node.METHOD_ARGUMENT_TYPE
    local method_arg = method_arguments[k]
    self:set_variable(method_arg.value, argumentValues[k])
  end

  -- Execute the block
  local blockReturnValue = self:visit(method.block)

  -- Return from our scope
  self.current_symbol_scope = self.current_symbol_scope:exitCall()
  return blockReturnValue
end

function Interpreter:ReturnStatement(node)
  return self:visit(node.expr)
end

function Interpreter:BreakStatement(node)
  return Symbols.Control.BREAK
end

function Interpreter:ContinueStatement(node)
  return Symbols.Control.CONTINUE
end

function Interpreter:FunctionCall(node)
  -- Get the function method
  -- note that this doesn't do chaining
  local method_invocation = node.method_invocation
  local classOrIdentifier = node.class

  -- If the "class" is actually a variable, then do a self class invocation
  -- E.g.
  --[[
    str = ""
    str.length <==> String.length(str)
  ]]

  local functionMethod
  local visitedArguments

  local identifierValue = self.current_symbol_scope:getVariable(classOrIdentifier, false)
  if (identifierValue ~= nil) then
    -- print("self call on var: " .. classOrIdentifier)

    -- This is a self call on the variable `stringVariable.length()`
    -- function class name is the type itself
    functionMethod = self:get_function_method(type(identifierValue), method_invocation.method_name)

    -- The argument is just our variable
    visitedArguments = {identifierValue}
  else
    -- print("func call on var: " .. classOrIdentifier)
    -- This is a standard function call Foo.doThing()
    functionMethod = self:get_function_method(classOrIdentifier, method_invocation.method_name)

    -- Each argument needs to be visited first!
    local k
    visitedArguments = {}
    for k = 1, method_invocation.num_arguments do
      -- This is some expression that needs to be visited for evaluation
      local invocation_arg = method_invocation.arguments[k]
      visitedArguments[k] = self:visit(invocation_arg)
    end
  end

  local functionReturnobject = functionMethod(self, self.wrapper, visitedArguments)
  if (functionReturnobject == nil) then
    return nil
  else
    -- Check if we have an error to throw
    if  (functionReturnobject.hasError) then
      self:error(functionReturnobject.errorMessage)
    end

    return functionReturnobject.result
  end
end

-- Note that the array is constructed here
function Interpreter:Array(node)
  local backingTable = node.backing_table

  -- Populate our table
  local k
  for k = 1, node.length do
    -- We have to visit everything before it reaches the array contents
    backingTable[k] = self:visit(node.arguments[k])
  end

  return backingTable
end

function Interpreter:ArrayIndexGet(node)
  -- Get the variable
  local identifierName = node.identifier
  local identifierTable = self:get_variable(identifierName)

  local index = self:visit(node.expr)
  if (Util.isNumber(index)) then
    -- The +1 is to allow 0 indexing
    index = index + 1
  end

  local tableValue = identifierTable[index]
  if (tableValue == nil) then
    self:error("Array indexing error on: <" .. identifierName .. "> at index: <" .. index .. ">")
  end

  return tableValue
end

-----------------------------------------------------------------------

-- For statements
-- They get their own section since they're complicated

-----------------------------------------------------------------------

function Interpreter:For_CollectionIteration(node)
  local iterator_variable_name = node.collectionVar
  local array_variable = self:visit(node.arrayExpr)

  for _,elementValue in pairs(array_variable) do
    self:set_variable(iterator_variable_name, elementValue)
    local returnValue = self:visit(node.block)

    if (returnValue ~= nil) then
      if (returnValue == Symbols.Control.BREAK) then
        -- break the loop entirely
        break
      elseif (returnValue == Symbols.Control.CONTINUE) then
        -- Continue execution onward. Since the StatementList has
        -- returned this value, we're good to just continue block execution
      else
        -- The return value is just a real return value
        return returnValue
      end
    end
  end
end

function Interpreter:For_Enhanced(node)
  self:visit(node.initializer)

  -- extract the variable
  local variable_name = node.initializer.left.value

  -- visit the condition value
  local condition_value = self:visit(node.condition)
  if (not Util.isNumber(condition_value)) then
    self:error("Expected for loop condition to evaluate to number")
  end

  local initializer_value = self:get_variable(variable_name)

  if (node.incrementer.type == Node.NO_OP_TYPE) then
    incrementer_value = 1
  else
    incrementer_value = self:visit(node.incrementer)
  end

  for i = initializer_value, (condition_value-1), incrementer_value do
    -- set i
    self:set_variable(variable_name, i)
    local returnValue = self:visit(node.block)

    if (returnValue ~= nil) then
      if (returnValue == Symbols.Control.BREAK) then
        -- break the loop entirely
        break
      elseif (returnValue == Symbols.Control.CONTINUE) then
        -- Continue execution onward. Since the StatementList has
        -- returned this value, we're good to just continue block execution
      else
        -- The return value is just a real return value
        return returnValue
      end
    end
  end
end

function Interpreter:For_Standard(node)
  self:visit(node.initializer)
  while self:visit(node.condition) do
    local returnValue = self:visit(node.block)

    if (returnValue ~= nil) then
      if (returnValue == Symbols.Control.BREAK) then
        -- break the loop entirely
        break
      elseif (returnValue == Symbols.Control.CONTINUE) then
        -- Continue execution onward. Since the StatementList has
        -- returned this value, we're good to just continue block execution
      else
        -- The return value is just a real return value
        return returnValue
      end
    end

    self:visit(node.incrementer)
  end
end

function Interpreter:For(node)
  --[[
    This is either a standard for loop, an enhanced for loop, or an iteration loop.

    Enhanced for-loops have the following structure:
    for (assignment ; number (; number) ) block

    Without this structure, we fallback to the standard for loop
  ]]

  -- We enter scope here since the initializer is inside the forloop scope itself
  -- e.g. for "(i=0..." the "i" shouldn't remain in scope afterwards
  self.current_symbol_scope = self.current_symbol_scope:enterBlock()

  local returnValue
  if (node.isCollectionIteration) then
    returnValue = self:For_CollectionIteration(node)
  else
    if (node.enhanced) then
      returnValue = self:For_Enhanced(node)
    else
      returnValue = self:For_Standard(node)
    end
  end

  self.current_symbol_scope = self.current_symbol_scope:exitBlock()
  return returnValue
end
