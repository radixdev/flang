require("base.util")

if not Flang then Flang = {} end
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
  end

  return m or ""
end

-- A recursive representation of the current node and all of it's children
function Node:display(tabs, info)
  local type = self.type
  local tabs = tabs or 0
  -- Info about the tree from the parent
  local info = info or ""
  local tabString = string.rep("  ", tabs) .. info
  local m = tostring(self)

  if (type == Node.NUMBER_TYPE) then
    print(tabString .. m)

  elseif (type == Node.BOOLEAN_TYPE) then
    print(tabString .. "boolean: " .. dq(self.value))

  elseif (type == Node.VARIABLE_TYPE) then
    print(tabString .. "var: " .. dq(self.value))

  elseif (type == Node.UNARY_OPERATOR_TYPE) then
    print(tabString .. "unary op: " .. dq(self.token.type))
    self.expr:display(tabs + 1)

  elseif (type == Node.BINARY_OPERATOR_TYPE) then
    print(tabString .. "bin op: " .. dq(self.token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (type == Node.NO_OP_TYPE) then
    print(tabString .. "no op")

  elseif (type == Node.ASSIGN_TYPE) then
    print(tabString .. "statement assign: " .. tostring(self.left.value))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (type == Node.STATEMENT_LIST_TYPE) then
    print(tabString .. "statement list")

    for key,childNode in ipairs(self.children) do
      print(key)
      childNode:display(tabs + 1)
    end

  elseif (type == Node.COMPARATOR_TYPE) then
    print(tabString .. "comparator op: " .. dq(self.token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)

  elseif (type == Node.NEGATION_TYPE) then
    print(tabString .. "negation: " .. dq(self.token.type))
    self.expr:display(tabs + 1)

  elseif (type == Node.IF_TYPE) then
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
  else
    print("Unknown type. Can't display parse tree: " .. dq(type))
  end
end
