require("base.scanner")
require("base.token")

if not Flang then Flang = {} end
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

  -- self:status()

  -- Read past any whitespace
  while Flang.Symbols.isWhitespace(self.c1) do
    token = Flang.Token:new(self.character)
    token.type = Flang.Symbols.WHITESPACE
    self:getChar()

    -- consume the rest of the whitespace
    while Flang.Symbols.isWhitespace(self.c1) do
      token.cargo = token.cargo .. self.c1
      self:getChar()

      -- only return this token if we want whitespace
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
end

function Lexer:status()
  print("c1: " .. dq(self.c1) .. "\tc2: " .. dq(self.c2) .. "\tchar: " .. tostring(self.character))
end

--[[
Wrap a string in quotes
]]
function dq(s)
  return "'" .. s .. "'"
end
