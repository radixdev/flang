require("base.util")

if not Flang then Flang = {} end
Node = {}
Flang.Node = Node
Node.__index = Node

--[[
A Node object represents a node in the AST passed from the parser to the
interpreter.
--]]

--[[
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

  setmetatable(o, self)
  self.__index = self
  return o
end

function Node.print(msg)
  print(msg)
end

-----------------------------------------------------------------------
-- Static node constructors
-----------------------------------------------------------------------

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

Node.NUMBER_TYPE = "Num"
function Node.Number(token)
  Node.print("creating num node " .. tostring(token))
  return Node:new({
    type = Node.NUMBER_TYPE,
    token = token,
    value = token.cargo
  })
end

Node.BOOLEAN_TYPE = "Bool"
function Node.Boolean(token)
  Node.print("creating boolean node " .. tostring(token))
  return Node:new({
    type = Node.BOOLEAN_TYPE,
    token = token,
    value = token.cargo
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

Node.NO_OP_TYPE = "NoOp"
function Node.NoOp()
  Node.print("creating no-op node")
  return Node:new({
    type = Node.NO_OP_TYPE
  })
end

Node.ASSIGN_TYPE = "Assign"
function Node.Assign(left, operator, right)
  Node.print("creating assign node: " .. dq(left) .. " and token " .. dq(left.value))
  return Node:new({
    type = Node.ASSIGN_TYPE,
    left = left,
    token = operator,
    right = right
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

Node.PROGRAM_TYPE = "Program"
function Node.Program()
  Node.print("creating program node")
  return Node:new({
    type = Node.PROGRAM_TYPE,
    -- As a polite aside, I fucking hate Lua so much
    -- No real arrays, and this joke of a substitute has to start at 1
    children = {},
    num_children = 1
  })
end

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

-- A non-recursive representation of this node
function Node:__tostring()
  m = "nodeType: " ..dq(self.type).. " "
  if (self.type == Node.NUMBER_TYPE) then
    m = m .. " value: " .. dq(self.value)
  elseif (self.type == Node.UNARY_OPERATOR_TYPE or self.type == Node.BINARY_OPERATOR_TYPE) then
    m = m .. " token: " .. dq(self.token)
  elseif (self.type == Node.VARIABLE_TYPE) then
    m = m .. " value: " .. dq(self.value)
  elseif (self.type == Node.BOOLEAN_TYPE) then
    m = m .. " value: " .. dq(self.value)
  elseif (self.type == Node.NO_OP_TYPE) then
    -- pass
  elseif (self.type == Node.ASSIGN_TYPE) then
    m = m .. " value: " .. dq(self.left.value)
  elseif (self.type == Node.PROGRAM_TYPE) then
    m = m .. " num statements: " .. dq(self.num_children)

  elseif (self.type == Node.COMPARATOR_TYPE) then
    m = m .. " token " .. dq(self.token)

  elseif (self.type == Node.NEGATION_TYPE) then
    m = m .. " token " .. dq(self.token)
  end

  return m or ""
end

-- A recursive representation of the current node and all of it's children
function Node:display(tabs)
  tabs = tabs or 0
  tabString = string.rep("   ", tabs)
  m = tostring(self)

  if (self.type == Node.NUMBER_TYPE) then
    print(tabString .. m)

  elseif (self.type == Node.BOOLEAN_TYPE) then
    print(tabString .. "boolean: " .. dq(self.value))

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
    print(tabString .. "statement assign: " .. tostring(self.left.value))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (self.type == Node.PROGRAM_TYPE) then
    print(tabString .. "program")

    for key,childNode in ipairs(self.children) do
      print(key)
      childNode:display(tabs + 1)
    end

  elseif (self.type == Node.COMPARATOR_TYPE) then
    print(tabString .. "comparator op: " .. dq(self.token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (self.type == Node.NEGATION_TYPE) then
    print(tabString .. "negation: " .. dq(self.token.type))
    self.expr:display(tabs + 1)

  else
    print("Unknown type. Can't display parse tree: " .. dq(self.type))
  end
end
