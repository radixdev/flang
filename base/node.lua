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

Node.BINARY_OPERATOR_TYPE = "binOp"
function Node.BinaryOperator(left, op, right)
  return Node:new({
    type = Node.BINARY_OPERATOR_TYPE,
    left = left,
    token = op,
    right = right
  })
end

Node.NUMBER_TYPE = "num"
function Node.Number(token)
  print("creating num node " .. tostring(token))
  return Node:new({
    type = Node.NUMBER_TYPE,
    token = token,
    value = token.cargo
  })
end

function Node:__tostring()
  m = "nodeType: " ..dq(self.type).. " "
  if (self.type == Node.NUMBER_TYPE) then
    m = m .. " value: " .. dq(self.token.cargo)
  elseif (self.type == Node.BINARY_OPERATOR_TYPE) then
    m = m .. " token: " .. dq(self.token)
  end

  return m or ""
end

function Node:display(tabs)
  m = tostring(self)

  if (self.type == Node.NUMBER_TYPE) then
    print(string.rep("\t", tabs) .. m)
  elseif (self.type == Node.BINARY_OPERATOR_TYPE) then
    print(string.rep("\t", tabs) .. "bin op: " .. tostring(self.token.type))
    self.right:display(tabs + 1)
    self.left:display(tabs + 1)
  end
end

--[[
Wrap a string or object in quotes
]]
function dq(s)
  return "'" .. tostring(s) .. "'"
end
