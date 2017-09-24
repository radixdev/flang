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

]]
function Parser:eat(token_type)
  if (self.current_token.type == token_type) then
    self.current_token = self.lexer:get()
    -- print("  Ate token " .. dq(token_type))
  else
    self:error("Expected " .. dq(token_type) .. " but got " .. dq(self.current_token.type) ..
                " at L" .. self.current_token.lineIndex .. ":C" .. self.current_token.columnIndex)
  end
end

--[[
  Takes a token type and eats if it exists in valid_token_types
]]
function Parser:eat_several(token_type, valid_token_types)
  if (Util.contains(valid_token_types, token_type)) then
    self:eat(token_type)
  --   print(" Ate several on token " .. dq(token_type))
  -- else
  --   print("did not eat token "..dq(token_type))
  end
end

-----------------------------------------------------------------------
-- AST generation
-----------------------------------------------------------------------

--[[
  FLANG 0.0.1 LANGUAGE DEFINITION

  program         : statement_list

  statement_list  : (statement)*
  statement       : assignment_statement
                  | if_statement
                  | for_statement
                  | empty

  assignment_statement      : variable (ASSIGN | ASSIGN_PLUS | ASSIGN_MINUS | ASSIGN_MUL | ASSIGN_DIV)  expr
  if_statement              : IF conditional block if_elseif
  for_statement             : FOR LPAREN assignment_statement SEMICOLON expr (SEMICOLON statement | SEMICOLON expr)? RPAREN block
  empty                     :

  if_elseif     : (ELSEIF conditional block)* if_else
  if_else       : ELSE block

  conditional   : LPAREN expr RPAREN
  block         : LBRACKET statement_list RBRACKET

  expr          : expr_cmp
  expr_cmp      : expr_plus ((GT | LT | GTE | LTE | CMP_EQUALS | CMP_NEQUALS) expr_plus)*
  expr_plus     : expr_mul ((PLUS | MINUS) expr_mul)*
  expr_mul      : factor ((MUL | DIV) factor)*
  factor        : NEGATE factor
                | PLUS factor
                | MINUS factor
                | NUMBER
                | LPAREN expr RPAREN
                | variable
                | boolean

  variable      : IDENTIFIER
  boolean       : (TRUE | FALSE)

]]

--[[
  http://www.cs.bilkent.edu.tr/~guvenir/courses/CS101/op_precedence.html
]]

function Parser:empty()
  -- Intentional no-op
  return Node.NoOp()
end

-----------------------------------------------------------------------
-- Expressions
-----------------------------------------------------------------------

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
  else
    return self:empty()
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

function Parser:expr_cmp()
  -- Comparators
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

-----------------------------------------------------------------------
-- Conditionals and if branching
-----------------------------------------------------------------------

function Parser:conditional()
  if (self.current_token.type == Symbols.LPAREN) then
    self:eat(Symbols.LPAREN)
    local node = self:expr()
    self:eat(Symbols.RPAREN)
    return node
  end
end

function Parser:if_else()
  -- if_else : (ELSE block)?
  if (self.current_token.type == Symbols.ELSE) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.ELSE)
    return Node.If(token, nil, self:block(), nil)
  end
end

function Parser:if_elseif()
  -- if_elseif : (ELSEIF conditional block)* if_else
  local node

  if (self.current_token.type == Symbols.ELSE) then
    return self:if_else()
  end

  while (self.current_token.type == Symbols.ELSEIF) do
    local token = Token:copy(self.current_token)

    self:eat(Symbols.ELSEIF)
    local cond = self:conditional()
    local block = self:block()

    node = Node.If(token, cond, block, self:if_elseif())
  end

  return node
end

-----------------------------------------------------------------------
-- Statements
-----------------------------------------------------------------------

function Parser:block()
  if (self.current_token.type == Symbols.LBRACKET) then
    self:eat(Symbols.LBRACKET)
    local node = self:statement_list()
    self:eat(Symbols.RBRACKET)
    return node
  end
end

function Parser:assignment_statement()
  --[[

    assignment_statement : variable (ASSIGN | ASSIGN_PLUS | ASSIGN_MINUS | ASSIGN_MUL | ASSIGN_DIV)  expr

  ]]

  local var_token = Token:copy(self.current_token)

  local left = self:variable()

  local assignment_token = Token:copy(self.current_token)
  valid_tokens = Util.Set{Symbols.EQUALS, Symbols.ASSIGN_PLUS,
      Symbols.ASSIGN_MINUS, Symbols.ASSIGN_MUL, Symbols.ASSIGN_DIV}
  self:eat_several(self.current_token.type, valid_tokens)

  local right = self:expr()

  return Node.Assign(left, var_token, right, assignment_token)
end

function Parser:if_statement()
  --[[

    if_statement : IF conditional block if_elseif

  ]]

  if (self.current_token.type == Symbols.IF) then
    local token = Token:copy(self.current_token)

    self:eat(Symbols.IF)
    local cond = self:conditional()
    local block = self:block()

    node = Node.If(token, cond, block, self:if_elseif())

    return node
  end
end

function Parser:for_statement()
  --[[

  for_statement : FOR LPAREN assignment_statement SEMICOLON expr (SEMICOLON statement | SEMICOLON expr)? RPAREN block

  ]]

  if (self.current_token.type == Symbols.FOR) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.FOR)
    self:eat(Symbols.LPAREN)

    local initializer = self:statement()
    self:eat(Symbols.SEMICOLON)

    local condition = self:expr()

    --[[
      the incrementer is either a number or empty (ENHANCED FOR) or a statement (STANDARD FOR)
      the incrementer can be an expression in the case of:
      for (i=0; 10; 2) {
        *BLOCK*
      }


    ]]
    local incrementer = self:empty()
    local enhanced = false
    if (self.current_token.type == Symbols.SEMICOLON) then
      self:eat(Symbols.SEMICOLON)

      incrementer = self:statement()
      if (incrementer.type == Node.NO_OP_TYPE) then
        -- no statement, check for an expression
        incrementer = self:expr()

        if (incrementer.type ~= Node.NO_OP_TYPE) then
          -- enhanced loop
          enhanced = true
        end
      end
    else
      enhanced = true
    end

    self:eat(Symbols.RPAREN)

    local block = self:block()

    return Node.For(token, initializer, condition, incrementer, block, enhanced)
  end
end

function Parser:statement()
  --[[

    statement     : assignment_statement
                  | if_statement
                  | for_statement
                  | empty

  ]]

  local token = self.current_token
  if (token.type == Symbols.IDENTIFIER) then
    node = self:assignment_statement()
  elseif (token.type == Symbols.IF) then
    node = self:if_statement()
  elseif (token.type == Symbols.FOR) then
    node = self:for_statement()
  else
    node = self:empty()
  end

  return node
end

function Parser:statement_list()
  --[[

    statement_list  : (statement)*

  ]]
  local parentNode = Node.StatementList()

  -- parse as long as we can
  while self.current_token.type ~= Symbols.EOF do
    local node = self:statement()

    -- If no valid statement can be found, then break out of the statement list
    if (node.type == Node.NO_OP_TYPE) then
      -- print("No valid statement found. Exiting parser.")
      break
    end

    local count = parentNode.num_children
    parentNode.children[count] = node
    parentNode.num_children = count + 1
  end

  -- If there's only 1 statement in the list, only return the 1 statement
  -- if (parentNode.num_children == 2) then
  --   return parentNode.children[1]
  -- end

  return parentNode
end

function Parser:program()
  --[[
    program   : statement_list
  ]]

  return self:statement_list()
end

-----------------------------------------------------------------------
-- Public interface
-----------------------------------------------------------------------

function Parser:parse()
  return self:program()
end