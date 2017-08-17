if not Flang then Flang = {} end
Symbols = {}
Flang.Symbols = Symbols
Symbols.__index = Symbols

-- turn the Table of {element, ...} into a table of {element = true, ...}
-- will be queried later
function Symbols.Set(table)
  local s = {}
  for _,v in pairs(table) do s[v] = true end
  return s
end

Symbols.TRUE = "true"
Symbols.FALSE = "false"
Symbols.IF = "if"
Symbols.ELSEIF = "elseif"
Symbols.ELSE = "else"
Symbols.FOR = "for"

Symbols.KEYWORDS = Symbols.Set{
  Symbols.IF,
  Symbols.ELSE,
  Symbols.ELSEIF,

  "while",
  Symbols.FOR,
  "print",

  Symbols.TRUE,
  Symbols.FALSE
}

Symbols.PLUS = "+"
Symbols.MINUS = "-"
Symbols.MUL = "*"
Symbols.DIV = "/"
Symbols.LPAREN = "("
Symbols.RPAREN = ")"
Symbols.EQUALS = "="
Symbols.GT = ">"
Symbols.LT = "<"
Symbols.NEGATE = "!"
Symbols.MODULUS = "%"
Symbols.LBRACKET = "{"
Symbols.RBRACKET = "}"
Symbols.SEMICOLON = ";"

Symbols.ONE_CHARACTER_SYMBOLS = Symbols.Set{
  Symbols.EQUALS,
  Symbols.LPAREN, Symbols.RPAREN,
  Symbols.LBRACKET, Symbols.RBRACKET,
  Symbols.LT, Symbols.GT,
  Symbols.DIV, Symbols.MUL, Symbols.PLUS, Symbols.MINUS,
  Symbols.NEGATE,
  Symbols.MODULUS,
  Symbols.SEMICOLON,
  "."
}

Symbols.GTE = ">="
Symbols.LTE = "<="
Symbols.CMP_EQUALS = "=="
Symbols.CMP_NEQUALS = "!="
Symbols.ASSIGN_PLUS = "+="
Symbols.ASSIGN_MINUS = "-="
Symbols.ASSIGN_MUL = "*="
Symbols.ASSIGN_DIV = "/="

Symbols.TWO_CHARACTER_SYMBOLS = Symbols.Set{
  Symbols.CMP_EQUALS,
  Symbols.CMP_NEQUALS,
  Symbols.LTE,
  Symbols.GTE,
  Symbols.ASSIGN_PLUS,
  Symbols.ASSIGN_MINUS,
  Symbols.ASSIGN_MUL,
  Symbols.ASSIGN_DIV,
  "&&",
  "||"
}

-- IDENTIFIER_STARTCHARS = string.letters
-- IDENTIFIER_CHARS      = string.letters + string.digits + "_"
--
-- NUMBER_STARTCHARS     = string.digits
-- NUMBER_CHARS          = string.digits + "."

Symbols.IDENTIFIER_STARTCHARS = Symbols.Set{"a", "b", "c", "d", "e", "f", "g", "h",
  "i", "j", "k", "l", "m", "n", "o", "p",
  "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
}
Symbols.IDENTIFIER_CHARS = Symbols.Set{"a", "b", "c", "d", "e", "f", "g", "h",
  "i", "j", "k", "l", "m", "n", "o", "p",
  "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

  "_"
}

Symbols.NUMBER_STARTCHARS     = Symbols.Set{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
Symbols.NUMBER_CHARS          = Symbols.Set{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."}

Symbols.STRING_STARTCHARS = Symbols.Set{"'", '"'}
Symbols.WHITESPACE_CHARS  = Symbols.Set{" ", "\t", "\n"}

-----------------------------------------------------------------------
-- TokenTypes for things other than symbols and keywords
-----------------------------------------------------------------------
Symbols.STRING             = "String"
Symbols.IDENTIFIER         = "Identifier"
Symbols.NUMBER             = "Number"
Symbols.WHITESPACE         = "Whitespace"
Symbols.COMMENT            = "Comment"
Symbols.EOF                = "Eof"

-----------------------------------------------------------------------
-- Set equality
-----------------------------------------------------------------------

-- Returns true if element in set, nil otherwise
function Symbols.contains(set, element)
  return set[element]
end

function Symbols.isKeyword(e)
  return Symbols.contains(Symbols.KEYWORDS, e)
end

function Symbols.isOneCharacterSymbol(e)
  return Symbols.contains(Symbols.ONE_CHARACTER_SYMBOLS, e)
end

function Symbols.isTwoCharacterSymbol(e)
  return Symbols.contains(Symbols.TWO_CHARACTER_SYMBOLS, e)
end

function Symbols.isWhitespace(e)
  return Symbols.contains(Symbols.WHITESPACE_CHARS, e)
end

function Symbols.isIdentifierStartChar(e)
  return Symbols.contains(Symbols.IDENTIFIER_STARTCHARS, e)
end

function Symbols.isIdentifierChar(e)
  return Symbols.contains(Symbols.IDENTIFIER_CHARS, e)
end

function Symbols.isNumberStartChar(e)
  return Symbols.contains(Symbols.NUMBER_STARTCHARS, e)
end

function Symbols.isNumberChar(e)
  return Symbols.contains(Symbols.NUMBER_CHARS, e)
end

function Symbols.isStringStartChar(e)
  return Symbols.contains(Symbols.STRING_STARTCHARS, e)
end
