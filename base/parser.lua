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

  expr      : term ((PLUS | MINUS) term)*
  term      : factor ((MUL | DIV) factor)*
  factor    : PLUS factor
            | MINUS factor
            | NUMBER
            | LPAREN expr RPAREN
            | variable
            | (TRUE | FALSE)
  variable  : IDENTIFIER

]]

function Parser:empty()
  -- Intentional no-op
  return Node.NoOp()
end

function Parser:variable()
  -- variable  : IDENTIFIER
  -- Note that we use the current token since we haven't eaten yet!
  node = Node.Variable(self.current_token)
  self:eat(Symbols.IDENTIFIER)
  return node
end

function Parser:factor()
  token = self.current_token
  if (token.type == Symbols.NUMBER) then
    -- NUMBER
    self:eat(Symbols.NUMBER)
    return Node.Number(self.prev_token)

  elseif (token.type == Symbols.PLUS) then
    -- ( PLUS ) factor
    self:eat(Symbols.PLUS)
    return Node.UnaryOperator(self.prev_token, self:factor())

  elseif (token.type == Symbols.MINUS) then
    -- ( MINUS ) factor
    self:eat(Symbols.MINUS)
    return Node.UnaryOperator(self.prev_token, self:factor())

  elseif (token.type == Symbols.LPAREN) then
    -- ( expr )
    self:eat(Symbols.LPAREN)
    node = self:expr()
    self:eat(Symbols.RPAREN)
    return node

  elseif (token.type == Symbols.IDENTIFIER) then
    node = self:variable()
    return node

  elseif (token.type == Symbols.TRUE) then
    self:eat(Symbols.TRUE)
    return node
  end

  self:error("Nothing to factor.")
end

function Parser:term()
  node = self:factor()

  while (self.current_token.type == Symbols.MUL or self.current_token.type == Symbols.DIV) do
    token = self.current_token
    if (token.type == Symbols.MUL) then
      self:eat(Symbols.MUL)
    elseif (token.type == Symbols.DIV) then
      self:eat(Symbols.DIV)
    end

    -- recursively build up the AST
    node = Node.BinaryOperator(node, self.prev_token, self:factor())
  end

  return node
end

function Parser:expr()
  node = self:term()

  while (self.current_token.type == Symbols.PLUS or self.current_token.type == Symbols.MINUS) do
    token = self.current_token
    if (token.type == Symbols.PLUS) then
      self:eat(Symbols.PLUS)
    elseif (token.type == Symbols.MINUS) then
      self:eat(Symbols.MINUS)
    end

    -- recursively build up the AST
    node = Node.BinaryOperator(node, self.prev_token, self:term())
  end

  return node
end

function Parser:assignment_statement()
  -- assignment_statement  : variable ASSIGN expr
  left = self:variable()
  self:eat(Symbols.EQUALS)
  right = self:expr()
  node = Node.Assign(left, self.prev_token, right)
  return node
end

function Parser:statement()
  --[[
  statement   : assignment_statement
              | empty
  ]]

  token = self.current_token
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
