Node = {}
Flang.Node = Node
Node.__index = Node

--[[
A Node object represents a node in the AST passed from the parser to the
interpreter.

Nodes only require a type. The object passed to this constructor could contains
whatever the node requires.
]]
function Node:new(o)
  if not o then
    error("nil constructor!")
  end

  if (o.type == nil) then
    error("Nodes require a type")
  end

  if (o.token ~= nil) then
    o.token_type = o.token.type
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

function Node.print(msg)
  if (Flang.VERBOSE_LOGGING) then
    print(msg)
  end
end

-----------------------------------------------------------------------
-- Static node constructors
-----------------------------------------------------------------------

Node.NUMBER_TYPE = "Num"
function Node.Number(token)
  Node.print("creating num node " .. tostring(token))
  return Node:new({
    type = Node.NUMBER_TYPE,
    token = token,
    value = token.cargo,
    parsed_value = tonumber(token.cargo)
  })
end

Node.BOOLEAN_TYPE = "Bool"
function Node.Boolean(token)
  Node.print("creating boolean node " .. tostring(token))
  return Node:new({
    type = Node.BOOLEAN_TYPE,
    token = token,
    value = token.cargo,
    parsed_value = (token.cargo == "true")
  })
end

Node.STRING_TYPE = "String"
function Node.String(token)
  Node.print("creating string node " .. tostring(token))
  return Node:new({
    type = Node.STRING_TYPE,
    token = token,
    value = token.cargo,
    -- Remove the quotes lol
    parsed_value = token.cargo:gsub("\"", "")
  })
end

Node.ARRAY_TYPE = "Array"
function Node.ArrayConstructor(token, arguments, length)
  Node.print("creating array constructor node " .. tostring(token))
  return Node:new({
    type = Node.ARRAY_TYPE,
    token = token,
    arguments = arguments,
    length = length,
    backing_table = {}
  })
end

Node.VARIABLE_TYPE = "Var"
function Node.Variable(token)
  Node.print("creating var node " .. tostring(token))
  return Node:new({
    type = Node.VARIABLE_TYPE,
    token = token,
    value = token.cargo
  })
end

Node.BINARY_OPERATOR_TYPE = "BinOp"
function Node.BinaryOperator(left, operator, right)
  Node.print("creating bin op node " .. tostring(operator))
  return Node:new({
    type = Node.BINARY_OPERATOR_TYPE,
    left = left,
    token = operator,
    right = right
  })
end

Node.UNARY_OPERATOR_TYPE = "UnaryOp"
function Node.UnaryOperator(operator, expr)
  Node.print("creating unary op node " .. tostring(operator))
  return Node:new({
    type = Node.UNARY_OPERATOR_TYPE,
    token = operator,
    expr = expr
  })
end

Node.NO_OP_TYPE = "NoOp"
function Node.NoOp()
  Node.print("creating no-op node")
  return Node:new({
    type = Node.NO_OP_TYPE
  })
end

--[[
  right: the expression to the right of the operator
]]
Node.ASSIGN_TYPE = "Assign"
function Node.Assign(left, operator, right, assignment_token)
  Node.print("creating assign node: " .. dq(left) .. " and token " .. dq(left.value))
  return Node:new({
    type = Node.ASSIGN_TYPE,
    left = left,
    token = operator,
    right = right,
    assignment_token = assignment_token
  })
end

Node.ARRAY_INDEX_ASSIGN_TYPE = "ArrayAssign"
function Node.ArrayAssign(left, indexExpr, operator, right, assignment_token)
  Node.print("creating array assign node: " .. dq(left) .. " and token " .. dq(left.value))
  return Node:new({
    type = Node.ARRAY_INDEX_ASSIGN_TYPE,
    left = left,
    indexExpr = indexExpr,
    token = operator,
    right = right,
    assignment_token = assignment_token
  })
end

Node.COMPARATOR_TYPE = "Cmp"
function Node.Comparator(left, operator, right)
  Node.print("creating comparator node: " .. dq(operator))
  return Node:new({
    type = Node.COMPARATOR_TYPE,
    left = left,
    token = operator,
    right = right
  })
end

Node.NEGATION_TYPE = "Negate"
function Node.Negation(operator, expr)
  Node.print("creating negation node " .. tostring(operator))
  return Node:new({
    type = Node.NEGATION_TYPE,
    token = operator,
    expr = expr
  })
end

Node.IF_TYPE = "If"
function Node.If(token, conditional, block, next_if)
  --[[
    An If statement. These nodes chain together to represent an if-elseif-else.

    The first "if" and subsequently chained "elseif" nodes should all contain a non-nil conditional
    and block. The "else" node should not contain a conditional.
  ]]
  Node.print("creating if node " .. tostring(token))
  return Node:new({
    type = Node.IF_TYPE,
    token = token,
    conditional = conditional,
    block = block,
    next_if = next_if
  })
end

Node.STATEMENT_LIST_TYPE = "StatementList"
function Node.StatementList()
  Node.print("creating StatementList node")
  return Node:new({
    type = Node.STATEMENT_LIST_TYPE,
    -- As a polite aside, I fucking hate Lua so much
    -- No real arrays, and this joke of a substitute has to start at 1
    children = {},
    num_children = 1
  })
end

Node.FOR_TYPE = "For"
function Node.For(token, initializer, condition, incrementer, block, enhanced)
  Node.print("creating for node " .. tostring(token))
  return Node:new({
    type = Node.FOR_TYPE,
    token = token,
    initializer = initializer,
    condition = condition,
    incrementer = incrementer,
    block = block,
    enhanced = enhanced
  })
end

--[[
  object . method ( arguments )

  the object is passed as an argument

  method_invocation is surprisingly a Node.METHOD_INVOCATION_TYPE
]]
Node.FUNCTION_CALL_TYPE = "FunctionCall"
function Node.FunctionCall(token, class, method_invocation)
  Node.print("creating function call node " .. tostring(token))
  return Node:new({
    type = Node.FUNCTION_CALL_TYPE,
    token = token,
    class = class,
    method_invocation = method_invocation
  })
end

--[[
  method_name . ( arguments )
  | method_name . ( arguments ) . next_method_invocation

  arguments = { 1 = something, 2 = something else, etc. }
]]
Node.METHOD_INVOCATION_TYPE = "MethodInvocation"
function Node.MethodInvocation(token, method_name, arguments, num_arguments, next_method_invocation)
  Node.print("creating method invocation node " .. tostring(token))
  return Node:new({
    type = Node.METHOD_INVOCATION_TYPE,
    token = token,
    method_name = method_name,
    arguments = arguments,
    num_arguments = num_arguments,
    next_method_invocation = next_method_invocation
  })
end

Node.METHOD_DEFINITION_TYPE = "MethodDefinition"
function Node.MethodDefinition(token, method_name, arguments, num_arguments, block)
  Node.print("creating method definition node " .. tostring(token))
  return Node:new({
    type = Node.METHOD_DEFINITION_TYPE,
    token = token,
    method_name = method_name,
    arguments = arguments,
    num_arguments = num_arguments,
    block = block
  })
end

Node.METHOD_ARGUMENT_TYPE = "MethodDefinitionArgument"
function Node.MethodDefinitionArgument(token)
  Node.print("creating method definition argument node " .. tostring(token))
  return Node:new({
    type = Node.METHOD_ARGUMENT_TYPE,
    token = token,
    value = token.cargo
  })
end

Node.RETURN_STATEMENT_TYPE = "ReturnStatement"
function Node.ReturnStatement(token, expr)
  Node.print("creating return statement node " .. tostring(token))
  return Node:new({
    type = Node.RETURN_STATEMENT_TYPE,
    token = token,
    expr = expr
  })
end

Node.ARRAY_INDEX_GET_TYPE = "ArrayIndexGet"
function Node.ArrayIndexGet(token, identifier, expr)
  Node.print("creating array index get node " .. tostring(token))
  return Node:new({
    type = Node.ARRAY_INDEX_GET_TYPE,
    token = token,
    identifier = identifier,
    expr = expr
  })
end

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

-- A non-recursive representation of this node
function Node:__tostring()
  local type = self.type
  local m = "nodeType: " ..dq(type).. " "
  if (type == Node.NUMBER_TYPE or type == Node.VARIABLE_TYPE or type == Node.BOOLEAN_TYPE) then
    m = m .. " value: " .. dq(self.value)
  end

  if (type == Node.COMPARATOR_TYPE or type == Node.NEGATION_TYPE
    or type == Node.UNARY_OPERATOR_TYPE or type == Node.BINARY_OPERATOR_TYPE) then
    m = m .. " token " .. dq(self.token)
  end

  if (type == Node.NO_OP_TYPE) then
    -- pass
  elseif (type == Node.ASSIGN_TYPE) then
    m = m .. " value: " .. dq(self.left.value)
  elseif (type == Node.STATEMENT_LIST_TYPE) then
    m = m .. " num statements: " .. dq(self.num_children)
  elseif (type == Node.FOR_TYPE) then
    m = m .. " for: " .. dq(self.token)
  elseif (type == Node.FUNCTION_CALL_TYPE) then
    m = m .. " func call: " .. dq(self.token)
  elseif (type == Node.METHOD_INVOCATION_TYPE) then
    m = m .. " method invocation: " .. dq(self.token)
  end

  return m or ""
end

-- A recursive representation of the current node and all of it's children
function Node:display(tabs, info)
  local tabs = tabs or 0
  -- Info about the tree from the parent
  local info = info or ""
  local tabString = string.rep("  ", tabs) .. info
  local m = tostring(self)

  if (self.type == Node.NUMBER_TYPE) then
    print(tabString .. m)

  elseif (self.type == Node.BOOLEAN_TYPE) then
    print(tabString .. "boolean: " .. dq(self.value))

  elseif (self.type == Node.STRING_TYPE) then
    print(tabString .. "string: " .. dq(self.value))

  elseif (self.type == Node.VARIABLE_TYPE) then
    print(tabString .. "var: " .. dq(self.value))

  elseif (self.type == Node.UNARY_OPERATOR_TYPE) then
    print(tabString .. "unary op: " .. dq(self.token.type))
    self.expr:display(tabs + 1)

  elseif (self.type == Node.BINARY_OPERATOR_TYPE) then
    print(tabString .. "bin op: " .. dq(self.token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (self.type == Node.NO_OP_TYPE) then
    print(tabString .. "no op")

  elseif (self.type == Node.ASSIGN_TYPE) then
    print(tabString .. "statement assign: " .. tostring(self.left.value) .. " sym: " .. dq(self.assignment_token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (self.type == Node.STATEMENT_LIST_TYPE) then
    print(tabString .. "STATEMENT LIST")

    for key,childNode in ipairs(self.children) do
      print(tabString .. key)
      childNode:display(tabs + 1)
    end

  elseif (self.type == Node.COMPARATOR_TYPE) then
    print(tabString .. "comparator op: " .. dq(self.token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (self.type == Node.NEGATION_TYPE) then
    print(tabString .. "negation: " .. dq(self.token.type))
    self.expr:display(tabs + 1)

  elseif (self.type == Node.IF_TYPE) then
    print(tabString .. "if: " .. dq(self.token.type))
    if self.conditional then
      self.conditional:display(tabs + 1, "CONDITIONAL: ")
    end
    if self.block then
      self.block:display(tabs + 1, "BLOCK: ")
    end
    if self.next_if then
      self.next_if:display(tabs + 2)
    end

  elseif (self.type == Node.FOR_TYPE) then
    print(tabString .. "for: " .. dq(self.token.type) .. " enhanced: " .. dq(self.enhanced))

    self.initializer:display(tabs + 1, "INITIALIZER: ")
    self.condition:display(tabs + 1, "CONDITIONAL: ")
    self.incrementer:display(tabs + 1, "INCREMENTER: ")
    self.block:display(tabs + 2)

  elseif (self.type == Node.FUNCTION_CALL_TYPE) then
    print(tabString .. "func call on: " .. dq(self.token.cargo))

    self.method_invocation:display(tabs + 1, "method: ")

  elseif (self.type == Node.METHOD_DEFINITION_TYPE) then
    print(tabString .. "method definition: " .. dq(self.method_name) .. " args: " .. Util.set_to_string(self.arguments))

    -- Recursively tell our block node to display itself
    -- at a (tabs + 1) deeper level
    self.block:display(tabs + 1, "BLOCK: ")

  elseif (self.type == Node.METHOD_INVOCATION_TYPE) then
    print(tabString .. "invocation " .. dq(self.method_name) .. " args: " .. Util.set_to_string(self.arguments))

    if self.next_method_invocation then
      self.next_method_invocation:display(tabs + 1, "Next method: ")
    end

  elseif (self.type == Node.RETURN_STATEMENT_TYPE) then
    print(tabString .. "return: " .. dq(self.token.type))
    self.expr:display(tabs + 1)

  elseif (self.type == Node.ARRAY_TYPE) then
    print(tabString .. "array constructor with args: " .. Util.set_to_string(self.arguments))

  elseif (self.type == Node.ARRAY_INDEX_GET_TYPE) then
    print(tabString .. "array index get on var: " .. dq(self.identifier))
    self.expr:display(tabs + 1)

  elseif (self.type == Node.ARRAY_INDEX_ASSIGN_TYPE) then
    print(tabString .. "statement array assign: " .. tostring(self.left.value) .. " sym: " .. dq(self.assignment_token.type))
    self.left:display(tabs + 1, "IDENTIFIER: ")
    self.indexExpr:display(tabs + 1, "INDEX: ")
    self.right:display(tabs + 1, "ASSIGNMENT: ")

  else
    print("Unknown type. Can't display parse tree: " .. dq(self.type))
  end
end
