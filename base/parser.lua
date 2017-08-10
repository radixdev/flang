require("base.symbols")
require("base.token")
require("base.node")
require("base.util")

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

Note: self.prev_token can also be thought of as "the last eaten token"

]]
function Parser:eat(token_type)
  if (self.current_token.type == token_type) then
    self.prev_token = self.current_token
    self.current_token = self.lexer:get()
    -- print("ate token " .. dq(token_type) .. " have token " .. dq(self.current_token))
  else
    self:error("Expected " .. dq(token_type) .. " but got " .. dq(self.current_token.type) ..
                " at L" .. self.current_token.lineIndex .. ":C" .. self.current_token.columnIndex)
  end
end

-----------------------------------------------------------------------
-- AST generation
-----------------------------------------------------------------------

--[[
  FLANG 0.0.1 LANGUAGE DEFINITION

  program         : statement
                  | (statement)*
  statement       : assignment_statement
                  | empty

  assignment_statement  : variable ASSIGN expr
  empty                 :

  expr        : expr_cmp
  expr_cmp    : expr_plus ((GT | LT | GTE | LTE | CMP_EQUALS | CMP_NEQUALS) expr_plus)*
  expr_plus   : expr_mul ((PLUS | MINUS) expr_mul)*
  expr_mul    : factor ((MUL | DIV) factor)*
  factor      : NEGATE factor
              | PLUS factor
              | MINUS factor
              | NUMBER
              | LPAREN expr RPAREN
              | variable
              | boolean
  variable    : IDENTIFIER
  boolean     : (TRUE | FALSE)

]]

--[[
  http://www.cs.bilkent.edu.tr/~guvenir/courses/CS101/op_precedence.html
]]

function Parser:empty()
  -- Intentional no-op
  return Node.NoOp()
end

function Parser:boolean()
  -- boolean   : (TRUE | FALSE)
  local token = Token:copy(self.current_token)
  if (token.type == Symbols.TRUE) then
    self:eat(Symbols.TRUE)
    return Node.Boolean(token)
  elseif (token.type == Symbols.FALSE) then
    self:eat(Symbols.FALSE)
    return Node.Boolean(token)
  end
end

function Parser:variable()
  -- variable  : IDENTIFIER
  -- Note that we use the current token since we haven't eaten yet!
  local node = Node.Variable(Token:copy(self.current_token))
  self:eat(Symbols.IDENTIFIER)
  return node
end

function Parser:factor()
  local token = Token:copy(self.current_token)

  if (token.type == Symbols.NUMBER) then
    -- NUMBER
    self:eat(Symbols.NUMBER)
    return Node.Number(token)

  elseif (token.type == Symbols.PLUS) then
    -- ( PLUS ) factor
    self:eat(Symbols.PLUS)
    return Node.UnaryOperator(token, self:factor())

  elseif (token.type == Symbols.MINUS) then
    -- ( MINUS ) factor
    self:eat(Symbols.MINUS)
    return Node.UnaryOperator(token, self:factor())

  elseif (token.type == Symbols.NEGATE) then
    self:eat(Symbols.NEGATE)
    return Node.Negation(token, self:factor())

  elseif (token.type == Symbols.LPAREN) then
    -- ( expr )
    self:eat(Symbols.LPAREN)
    local node = self:expr()
    self:eat(Symbols.RPAREN)
    return node

  elseif (token.type == Symbols.IDENTIFIER) then
   return self:variable()

  elseif (token.type == Symbols.TRUE or token.type == Symbols.FALSE) then
    return self:boolean()
  end
end

function Parser:expr_mul()
  local node = self:factor()

  while (self.current_token.type == Symbols.MUL
        or self.current_token.type == Symbols.MODULUS
        or self.current_token.type == Symbols.DIV) do
    local token = Token:copy(self.current_token)
    if (token.type == Symbols.MUL) then
      self:eat(Symbols.MUL)
    elseif (token.type == Symbols.DIV) then
      self:eat(Symbols.DIV)
    elseif (token.type == Symbols.MODULUS) then
      self:eat(Symbols.MODULUS)
    end

    -- recursively build up the AST
    node = Node.BinaryOperator(node, token, self:factor())
  end

  return node
end

function Parser:expr_plus()
  local node = self:expr_mul()

  while (self.current_token.type == Symbols.PLUS or self.current_token.type == Symbols.MINUS) do
    local token = Token:copy(self.current_token)
    if (token.type == Symbols.PLUS) then
      self:eat(Symbols.PLUS)
    elseif (token.type == Symbols.MINUS) then
      self:eat(Symbols.MINUS)
    end

    -- recursively build up the AST
    node = Node.BinaryOperator(node, token, self:expr_mul())
  end

  return node
end

--[[
Comparators
]]
function Parser:expr_cmp()
  local node = self:expr_plus()

  while (self.current_token.type == Symbols.GT or self.current_token.type == Symbols.LT
        or self.current_token.type == Symbols.GTE or self.current_token.type == Symbols.LTE
        or self.current_token.type == Symbols.CMP_EQUALS or self.current_token.type == Symbols.CMP_NEQUALS) do

    local token = Token:copy(self.current_token)
    if (token.type == Symbols.GT) then
      self:eat(Symbols.GT)
    elseif (token.type == Symbols.LT) then
      self:eat(Symbols.LT)
    elseif (token.type == Symbols.GTE) then
      self:eat(Symbols.GTE)
    elseif (token.type == Symbols.LTE) then
      self:eat(Symbols.LTE)
    elseif (token.type == Symbols.CMP_EQUALS) then
      self:eat(Symbols.CMP_EQUALS)
    elseif (token.type == Symbols.CMP_NEQUALS) then
      self:eat(Symbols.CMP_NEQUALS)
    end

    node = Node.Comparator(node, token, self:expr_plus())
  end

  return node
end

function Parser:expr()
  return self:expr_cmp()
end

function Parser:assignment_statement()
  -- assignment_statement  : variable ASSIGN expr
  local left = self:variable()
  self:eat(Symbols.EQUALS)
  local right = self:expr()

  return Node.Assign(left, self.prev_token, right)
end

function Parser:statement()
  --[[
  statement   : assignment_statement
              | empty
  ]]

  local token = self.current_token
  if (token.type == Symbols.IDENTIFIER) then
    node = self:assignment_statement()
  else
    node = self:empty()
  end

  return node
end

function Parser:program()
  --[[
  program   : statement
            | (statement)*
  ]]
  parentNode = Node.Program()

  -- parse as long as we can
  while self.current_token.type ~= Symbols.EOF do
    node = self:statement()

    count = parentNode.num_children
    parentNode.children[count] = node
    parentNode.num_children = count + 1

    -- If no valid statement can be found, then exit with nothing
    if (node.type == Node.NO_OP_TYPE) then
      print("No valid statement found. Exiting parser.")
      break
    end
  end

  return parentNode
end

-----------------------------------------------------------------------
-- Public interface
-----------------------------------------------------------------------

function Parser:parse()
  return self:program()
end
