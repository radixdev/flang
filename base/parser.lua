--[[

    expr   : term ((PLUS | MINUS) term)*
    term   : factor ((MUL | DIV) factor)*
    factor : NUMBER | LPAREN expr RPAREN

]]

require("base.symbols")
require("base.token")
require("base.node")

if not Flang then Flang = {} end
Parser = {}
Flang.Parser = Parser
Parser.__index = Parser

function Parser:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    lexer = o.lexer
  }

  o.current_token = lexer:get()
  o.prev_token = nil

  setmetatable(o, self)
  self.__index = self
  return o
end

function Parser:error(msg)
  error(msg)
end

--[[

Compare the current token with the input token type. If the match, then
"eat" the current token and assign the next token to "self.current_token".

Else, throw an exception ;)

]]
function Parser:eat(token_type)
  if (self.current_token.type == token_type) then
    self.prev_token = self.current_token
    self.current_token = self.lexer:get()
  else
    self:error("Expecting token with type " .. dq(token_type) .. " but have token with type " .. dq(self.current_token.type))
  end
end

function Parser:factor()
  token = self.current_token
  if (token.type == Symbols.NUMBER) then
    self:eat(Symbols.NUMBER)
    return Node.Number(self.prev_token)
  elseif (token.type == "(") then
    self:eat("(")
    node = self:expr()
    self:eat(")")
    return node
  else
    -- at this point, we have nothing to return and some poor node was expecting something
    self:error("Nothing to return in factor.")
  end
end

function Parser:term()
  node = self:factor()

  while (self.current_token.type == "*" or self.current_token.type == "/") do
    token = self.current_token
    if (token.type == "*") then
      self:eat("*")
    elseif (token.type == "/") then
      self:eat("/")
    end

    -- recursively build up the AST
    node = Node.BinaryOperator(node, self.prev_token, self:factor())
  end

  return node
end

function Parser:expr()
  node = self:term()

  while (self.current_token.type == "+" or self.current_token.type == "-") do
    token = self.current_token
    if (token.type == "+") then
      self:eat("+")
    elseif (token.type == "-") then
      self:eat("-")
    end

    -- recursively build up the AST
    node = Node.BinaryOperator(node, self.prev_token, self:term())
  end

  return node
end

function Parser:parse()
  return self:expr()
end

--[[
Wrap a string or object in quotes
]]
function dq(s)
  return "'" .. tostring(s) .. "'"
end
