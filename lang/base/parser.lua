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

  o.current_token = o.lexer:get()
  o.next_token = o.lexer:get()

  setmetatable(o, self)
  self.__index = self
  return o
end

function Parser:error(msg)
  local errorMsg = msg .. "\nat " .. Util.set_to_string_dumb(self.current_token)
  local source = self.lexer.sourceText
  local errorLine = self.current_token.lineIndex - 1

  local linesMsg = Util.getLineNumbers(source, errorLine - 2, 4)
  error(errorMsg .. linesMsg)
end

--[[

  Compare the current token with the input token type. If the match, then
  "eat" the current token and assign the next token to "self.current_token".

  Else, throw an exception ;)

]]
function Parser:eat(token_type)
  if (self.current_token.type == token_type) then
    if (Flang.VERBOSE_LOGGING) then
      print("Ate token " .. dq(token_type) .. " with body: " .. dq(self.current_token))
    end

    self.current_token = Token:copy(self.next_token)
    self.next_token = Token:copy(self.lexer:get())
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
  FLANG LANGUAGE DEFINITION

  program         : statement_list

  statement_list  : (statement)*
  statement       : assignment_statement
                  | array_index_assign_statement
                  | if_statement
                  | (for_statement | for_collection_statement)
                  | method_definition_statement
                  | return_statement
                  | break_statement
                  | continue_statement
                  | function_call
                  | empty

  assignment_statement          : variable (ASSIGN | ASSIGN_PLUS | ASSIGN_MINUS | ASSIGN_MUL | ASSIGN_DIV) expr
  array_index_assign_statement  : variable LSQUAREBRACKET expr RSQUAREBRACKET (ASSIGN | ASSIGN_PLUS | ASSIGN_MINUS | ASSIGN_MUL | ASSIGN_DIV) expr
  if_statement                  : IF conditional block if_elseif
  for_statement                 : FOR LPAREN (for_body_standard | for_body_collection) RPAREN block
  method_definition_statement   : DEF IDENTIFIER LPAREN (method_definition_argument COMMA | method_definition_argument)* RPAREN block
  return_statement              : RETURN expr
  break_statement               : BREAK
  continue_statement            : CONTINUE
  empty                         :

  for_body_standard             : assignment_statement SEMICOLON expr (SEMICOLON statement | SEMICOLON expr)?
  for_body_collection           : variable (COMMA variable)? IN ARRAY

  if_elseif     : (ELSEIF conditional block)* if_else
  if_else       : ELSE block

  conditional   : LPAREN expr RPAREN
  block         : LBRACKET statement_list RBRACKET

  expr          : expr_log_or
  expr_log_or   : expr_log_and (LOGICAL_OR expr_log_and)*
  expr_log_and  : expr_cmp (LOGICAL_AND expr_cmp)*
  expr_cmp      : expr_plus ((GT | LT | GTE | LTE | CMP_EQUALS | CMP_NEQUALS) expr_plus)*
  expr_plus     : expr_mul ((PLUS | MINUS) expr_mul)*
  expr_mul      : factor ((MUL | DIV) factor)*
  factor        : NEGATE factor
                | PLUS factor
                | MINUS factor
                | NUMBER
                | boolean
                | STRING
                | array_init
                | (variable | function_call | array_index_get)
                | LPAREN expr RPAREN

  variable      : IDENTIFIER
  boolean       : (TRUE | FALSE)

  array_init        : LSQUAREBRACKET (expr COMMA | expr)* RSQUAREBRACKET
  array_index_get   : IDENTIFIER LSQUAREBRACKET expr RSQUAREBRACKET

  function_call              : (IDENTIFIER DOT)? IDENTIFIER LPAREN (argument COMMA | argument)* RPAREN
  argument                   : expr
  method_definition_argument : IDENTIFIER

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

function Parser:variable(token)
  -- variable  : IDENTIFIER
  local node = Node.Variable(Token:copy(self.current_token))

  self:eat(Symbols.IDENTIFIER)
  return node
end

function Parser:method_definition_argument()
  local token = Token:copy(self.current_token)
  self:eat(Symbols.IDENTIFIER)
  return Node.MethodDefinitionArgument(token)
end

--[[
  Gets the invocation chain
]]
function Parser:method_invocation()
  -- start with the method identifier
  local token = Token:copy(self.current_token)
  self:eat(Symbols.IDENTIFIER)

  -- now onto the parens and arguments
  self:eat(Symbols.LPAREN)

  -- Now parse the arguments
  -- Start at 1 to iterate in LUA
  local num_arguments = 0
  local args = {}

  while (self.current_token.type ~= Symbols.RPAREN) do
    local token = Token:copy(self.current_token)
    -- parse the arguments
    if (token.type == Symbols.COMMA) then
      -- prep for the next argument
      self:eat(Symbols.COMMA)
    else
      args[#args + 1] = self:expr()
      num_arguments = num_arguments + 1
    end
  end

  self:eat(Symbols.RPAREN)

  local method_name = token.cargo
  if (self.current_token.type == Symbols.DOT) then
    -- This is for continued method invocations like:
    -- Foo.add().continued_invocation1().continued_invocation2()
    self:eat(Symbols.DOT)
    return Node.MethodInvocation(token, method_name, args, num_arguments, self:method_invocation())
  else
    return Node.MethodInvocation(token, method_name, args, num_arguments, nil)
  end
end

function Parser:array_index_assign()
  -- start with the array identifier
  local var_token = Token:copy(self.current_token)
  local left = self:variable()

  -- now onto the index
  self:eat(Symbols.LSQUAREBRACKET)
  local indexExpr = self:expr()
  self:eat(Symbols.RSQUAREBRACKET)

  -- Now onto the rest of the statement
  local assignment_token = Token:copy(self.current_token)
  valid_tokens = Util.Set{Symbols.EQUALS, Symbols.ASSIGN_PLUS,
      Symbols.ASSIGN_MINUS, Symbols.ASSIGN_MUL, Symbols.ASSIGN_DIV}
  self:eat_several(self.current_token.type, valid_tokens)

  local right = self:expr()
  return Node.ArrayAssign(left, indexExpr, var_token, right, assignment_token)
end

function Parser:array_index_get()
  -- start with the array identifier
  local token = Token:copy(self.current_token)
  self:eat(Symbols.IDENTIFIER)

  -- now onto the index
  self:eat(Symbols.LSQUAREBRACKET)

  -- There's some expr inside the []
  local expr = self:expr()

  self:eat(Symbols.RSQUAREBRACKET)
  return Node.ArrayIndexGet(token, token.cargo, expr)
end

function Parser:function_invocation()
  -- This is a `Foo.method()` type call
  -- firstIdentifier is the object
  local firstIdentifier = Token:copy(self.current_token)
  self:eat(Symbols.IDENTIFIER)
  self:eat(Symbols.DOT)

  return Node.FunctionCall(firstIdentifier, firstIdentifier.cargo, self:method_invocation())
end

function Parser:array_constructor()
  -- start with the bracket
  local token = Token:copy(self.current_token)
  self:eat(Symbols.LSQUAREBRACKET)

  -- Now parse the arguments
  -- Start at 1 to iterate in LUA
  local length = 0
  local args = {}

  while (self.current_token.type ~= Symbols.RSQUAREBRACKET) do
    local token = Token:copy(self.current_token)
    -- parse the arguments
    if (token.type == Symbols.COMMA) then
      -- prep for the next argument
      self:eat(Symbols.COMMA)
    else
      args[#args + 1] = self:expr()
      length = length + 1
    end
  end

  self:eat(Symbols.RSQUAREBRACKET)

  -- return a constructor node
  return Node.ArrayConstructor(token, args, length)
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

  elseif (token.type == Symbols.TRUE or token.type == Symbols.FALSE) then
    return self:boolean()

  elseif (token.type == Symbols.STRING) then
    self:eat(Symbols.STRING)
    return Node.String(token)

  elseif (token.type == Symbols.LSQUAREBRACKET) then
    -- Array construction
    return self:array_constructor()

  elseif (token.type == Symbols.IDENTIFIER) then
    -- Do a lookahead. This identifier can't be assigned just yet

    if (self.next_token.type == Symbols.DOT) then
      -- This is a `Foo.method()` type call
      return self:function_invocation()

    elseif (self.next_token.type == Symbols.LPAREN) then
      -- This is just a `method()` call
      return self:method_invocation()

    elseif (self.next_token.type == Symbols.LSQUAREBRACKET) then
      -- This is an array indexing call `arr[i]`
      return self:array_index_get()

    else
      -- just a regular variable
      return self:variable()
    end

    self:error("Expected a variable or object call or method invocation. Or something idk cmon.")

  elseif (token.type == Symbols.LPAREN) then
    -- ( expr )
    self:eat(Symbols.LPAREN)
    local node = self:expr()
    self:eat(Symbols.RPAREN)
    return node

  else
    self:error("Error, Parser.factor() has cannot continue. Are you trying to call a method on a primitive? Did you not close a brace somewhere? File an issue at https://github.com/radixdev/flang/issues")
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

function Parser:expr_log_and()
  local node = self:expr_cmp()

  while (self.current_token.type == Symbols.LOGICAL_AND) do
    local token = Token:copy(self.current_token)
    if (token.type == Symbols.LOGICAL_AND) then
      self:eat(Symbols.LOGICAL_AND)
    end

    node = Node.LogicalAnd(node, token, self:expr_cmp())
  end

  return node
end

function Parser:expr_log_or()
  local node = self:expr_log_and()

  while (self.current_token.type == Symbols.LOGICAL_OR) do
    local token = Token:copy(self.current_token)
    if (token.type == Symbols.LOGICAL_OR) then
      self:eat(Symbols.LOGICAL_OR)
    end

    node = Node.LogicalOr(node, token, self:expr_log_and())
  end

  return node
end

function Parser:expr()
  return self:expr_log_or()
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

    for_statement         : FOR LPAREN (for_body_standard | for_body_collection) RPAREN block
    for_body_standard     : assignment_statement SEMICOLON expr (SEMICOLON statement | SEMICOLON expr)?
    for_body_collection   : variable IN ARRAY

  ]]

  if (self.current_token.type == Symbols.FOR) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.FOR)
    self:eat(Symbols.LPAREN)

    local initializer
    local incrementer
    local arrayExpr
    local enhanced
    local condition
    local isCollectionIteration
    local iteratorKeyVar
    local iteratorValueVar

    -- This could be a iterator type loop `for (i in array)`
    -- The next token would be `in` or a comma
    local nextTokenType = self.next_token.type
    if (self.current_token.type == Symbols.IDENTIFIER and nextTokenType == Symbols.IN) then
      isCollectionIteration = true
      -- Get the iterator variable
      token = self.current_token
      self:eat(Symbols.IDENTIFIER)
      self:eat(Symbols.IN)

      -- Get the collection
      arrayExpr = self:expr()

      iteratorValueVar = token.cargo
    elseif (self.current_token.type == Symbols.IDENTIFIER and nextTokenType == Symbols.COMMA) then
      print("yeet")
      isCollectionIteration = true

      -- Get the iterator key variable
      token = self.current_token
      iteratorKeyVar = token.cargo
      self:eat(Symbols.IDENTIFIER)

      -- Get the value variable
      self:eat(Symbols.COMMA)
      iteratorValueVar = self.current_token.cargo
      self:eat(Symbols.IDENTIFIER)

      -- Now for the rest of the for statement
      self:eat(Symbols.IN)

      -- Get the collection
      arrayExpr = self:expr()
    else
      -- standard for body
      initializer = self:statement()
      self:eat(Symbols.SEMICOLON)

      condition = self:expr()

      --[[
        the incrementer is either a number or empty (ENHANCED FOR) or a statement (STANDARD FOR)
        the incrementer can be an expression in the case of:
        for (i=0; 10; 2) {
          *BLOCK*
        }
      ]]
      incrementer = self:empty()
      enhanced = false
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
    end

    self:eat(Symbols.RPAREN)
    local block = self:block()
    return Node.For(token, initializer, condition, incrementer, block, enhanced,
                    iteratorKeyVar, iteratorValueVar, arrayExpr, isCollectionIteration)
  end
end

function Parser:method_definition_statement()
  --[[

    method_definition_statement   : DEF IDENTIFIER LPAREN method_arguments RPAREN block

    method_arguments : (IDENTIFIER COMMA | IDENTIFIER)*

  ]]

  -- Check if we actually have a method def
  if (self.current_token.type == Symbols.DEF) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.DEF)

    -- method name is just an identifier, so we'll eat it after
    local method_name = self.current_token.cargo
    self:eat(Symbols.IDENTIFIER)
    self:eat(Symbols.LPAREN)

    -- Parse the arguments
    -- Start at 1 to iterate in LUA
    local num_arguments = 0
    local arguments = {}

    while (self.current_token.type ~= Symbols.RPAREN) do
      local token = Token:copy(self.current_token)
      -- parse the arguments
      if (token.type == Symbols.COMMA) then
        -- prep for the next argument
        self:eat(Symbols.COMMA)
      else
        arguments[#arguments + 1] = self:method_definition_argument()
        num_arguments = num_arguments + 1
      end
    end

    self:eat(Symbols.RPAREN)
    local block = self:block()

    -- All done, now return a definition node
    return Node.MethodDefinition(token, method_name, arguments, num_arguments, block)
  end
end

function Parser:return_statement()
  -- return_statement : RETURN expr
  if (self.current_token.type == Symbols.RETURN) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.RETURN)

    local expr = self:expr()
    return Node.ReturnStatement(token, expr)
  end
end

function Parser:break_statement()
  if (self.current_token.type == Symbols.BREAK) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.BREAK)
    return Node.BreakStatement(token)
  end
end

function Parser:continue_statement()
  if (self.current_token.type == Symbols.CONTINUE) then
    local token = Token:copy(self.current_token)
    self:eat(Symbols.CONTINUE)
    return Node.ContinueStatement(token)
  end
end

function Parser:statement()
  --[[

    statement       : assignment_statement
                    | if_statement
                    | for_statement
                    | method_definition_statement
                    | return_statement
                    | function_call
                    | empty

  ]]

  local token = self.current_token
  local nextToken = self.next_token
  if (token.type == Symbols.IDENTIFIER) then
    -- Do a lookahead. This identifier can't be assigned just yet

    if (nextToken.type == Symbols.DOT) then
      return self:function_invocation()

    elseif (nextToken.type == Symbols.LPAREN) then
      -- This is just a `method()` call
      return self:method_invocation()

    elseif (nextToken.type == Symbols.LSQUAREBRACKET) then
      -- This is an array set `array[index] = blah`
      return self:array_index_assign()

    else
      return self:assignment_statement()
    end

  elseif (token.type == Symbols.IF) then
    node = self:if_statement()

  elseif (token.type == Symbols.FOR) then
    node = self:for_statement()

  elseif (token.type == Symbols.DEF) then
    node = self:method_definition_statement()

  elseif (token.type == Symbols.RETURN) then
    node = self:return_statement()

  elseif (token.type == Symbols.BREAK) then
    node = self:break_statement()

  elseif (token.type == Symbols.CONTINUE) then
    node = self:continue_statement()

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
