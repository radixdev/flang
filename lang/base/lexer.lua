Lexer = {}
Flang.Lexer = Lexer
Lexer.__index = Lexer

function Lexer:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    sourceText = o.sourceText,
    c1 = "",
    c2 = "",
    character = nil
  }
  -- Create a scanner and initialize it
  o.scanner = Flang.Scanner:new({sourceText = o.sourceText})

  setmetatable(o, self)
  self.__index = self

  return o
end

--[[
Construct and return the next token in the text
]]
function Lexer:get()
  if (self.character == nil) then
    self:getChar()
  end

  -- Read past any whitespace
  while Flang.Symbols.isWhitespace(self.c1) do
    self:getChar()
  end

  -- Consume any comments until we verifiably get to a non-comment
  while (self.c2 == Flang.Symbols.SINGLE_LINE_COMMENT_START) do
    self:getChar()

    -- Eat everything until the line is over
    while (self.c1 ~= Symbols.NEWLINE and self.c1 ~= Flang.Character.ENDMARK) do
      self:getChar()
    end

    -- trim up any trailing characters
    while Flang.Symbols.isWhitespace(self.c1) do
      self:getChar()
    end
  end

  -- Create a token and consume info!
  token = Flang.Token:new(self.character)

  if (self.c1 == Flang.Character.ENDMARK) then
    token.type = Flang.Symbols.EOF
    return token
  end

  -- parse an identifier
  if (Flang.Symbols.isIdentifierStartChar(self.c1)) then
    token.type = Flang.Symbols.IDENTIFIER
    self:getChar()

    -- get the entire identifier
    while (Flang.Symbols.isIdentifierChar(self.c1)) do
      token.cargo = token.cargo .. self.c1
      self:getChar()
    end

    -- check if the token is a keyword
    if (Flang.Symbols.isKeyword(token.cargo)) then
      token.type = token.cargo
    end

    return token
  end

  -- numbers
  if (Flang.Symbols.isNumberStartChar(self.c1)) then
    token.type = Flang.Symbols.NUMBER
    self:getChar()

    -- get the entire number
    -- TODO Make sure "." doesn't exist more than once in the number
    while (Flang.Symbols.isNumberChar(self.c1)) do
      token.cargo = token.cargo .. self.c1
      self:getChar()
    end

    return token
  end

  -- strings!
  if (Flang.Symbols.isStringStartChar(self.c1)) then
    -- remember the quoteChar (single or double quote)
    -- so we can look for the same character to terminate the quote.

    startingQuoteChar = self.c1
    self:getChar()

    -- consume the string contents
    while (self.c1 ~= startingQuoteChar) do
      if (self.c1 == Flang.Character.ENDMARK) then
        token:abort("Found end of file before end of string literal")
      end

      token.cargo = token.cargo .. self.c1
      self:getChar()
    end

    -- The string is done. Add the quote to finish the string
    token.cargo = token.cargo .. self.c1
    self:getChar()
    token.type = Flang.Symbols.STRING
    return token
  end

  -- two character symbols before one character symbols
  if (Flang.Symbols.isTwoCharacterSymbol(self.c2)) then
    token.cargo = self.c2
    -- For symbols, the token type is the same as the cargo
    token.type = token.cargo

    self:getChar() -- read past the first  character of a 2-character token
    self:getChar() -- read past the second character of a 2-character token
    return token
  end

  -- one character symbols
  if (Flang.Symbols.isOneCharacterSymbol(self.c1)) then
    -- For symbols, the token type is the same as the cargo
    token.type = token.cargo

    self:getChar() -- read past the symbol
    return token
  end

  -- At this point, who the hell knows what got returned. Throw an error
  token:abort("Unknown character or symbol in lexer: " .. dq(self.c1))
end

--[[
Get the next character string
]]
function Lexer:getChar()
  self.character = self.scanner:get()

  -- get the first character string
  self.c1 = self.character.cargo

  -- get the concatenation of the current character and the next one
  self.c2 = self.c1 .. self.scanner:lookahead(1)

  if Flang.VERBOSE_LOGGING then
    self:status()
  end
end

function Lexer:status()
  local status = "  c1: " .. dq(self.c1) .. "\tc2: " .. dq(self.c2) .. "\tchar: " .. tostring(self.character)
  print(status:gsub("\n", "\\n"))
end
