Symbols = {}
Flang.Symbols = Symbols
Symbols.__index = Symbols

Symbols.TRUE = "true"
Symbols.FALSE = "false"
Symbols.IF = "if"
Symbols.ELSEIF = "elseif"
Symbols.ELSE = "else"
Symbols.FOR = "for"
Symbols.DEF = "def"

Symbols.KEYWORDS = Flang.Util.Set{
  Symbols.IF,
  Symbols.ELSE,
  Symbols.ELSEIF,

  "while",
  Symbols.FOR,
  "print",
  Symbols.DEF,

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
Symbols.COMMA = ","
Symbols.DOT = "."

Symbols.ONE_CHARACTER_SYMBOLS = Flang.Util.Set{
  Symbols.EQUALS,
  Symbols.LPAREN, Symbols.RPAREN,
  Symbols.LBRACKET, Symbols.RBRACKET,
  Symbols.LT, Symbols.GT,
  Symbols.DIV, Symbols.MUL, Symbols.PLUS, Symbols.MINUS,
  Symbols.NEGATE,
  Symbols.MODULUS,
  Symbols.SEMICOLON,
  Symbols.COMMA,
  Symbols.DOT
}

Symbols.GTE = ">="
Symbols.LTE = "<="
Symbols.CMP_EQUALS = "=="
Symbols.CMP_NEQUALS = "!="
Symbols.ASSIGN_PLUS = "+="
Symbols.ASSIGN_MINUS = "-="
Symbols.ASSIGN_MUL = "*="
Symbols.ASSIGN_DIV = "/="
Symbols.SINGLE_LINE_COMMENT_START = "//"

Symbols.TWO_CHARACTER_SYMBOLS = Flang.Util.Set{
  Symbols.CMP_EQUALS,
  Symbols.CMP_NEQUALS,
  Symbols.LTE,
  Symbols.GTE,
  Symbols.ASSIGN_PLUS,
  Symbols.ASSIGN_MINUS,
  Symbols.ASSIGN_MUL,
  Symbols.ASSIGN_DIV,
  "&&",
  "||",
  Symbols.SINGLE_LINE_COMMENT_START
}

-- IDENTIFIER_STARTCHARS = string.letters
-- IDENTIFIER_CHARS      = string.letters + string.digits + "_"
--
-- NUMBER_STARTCHARS     = string.digits
-- NUMBER_CHARS          = string.digits + "."

Symbols.IDENTIFIER_STARTCHARS = Flang.Util.Set{"a", "b", "c", "d", "e", "f", "g", "h",
  "i", "j", "k", "l", "m", "n", "o", "p",
  "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
}
Symbols.IDENTIFIER_CHARS = Flang.Util.Set{"a", "b", "c", "d", "e", "f", "g", "h",
  "i", "j", "k", "l", "m", "n", "o", "p",
  "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

  "_"
}

Symbols.NUMBER_STARTCHARS     = Flang.Util.Set{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
Symbols.NUMBER_CHARS          = Flang.Util.Set{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."}

Symbols.STRING_STARTCHARS = Flang.Util.Set{"'", '"'}
Symbols.NEWLINE = "\n"
Symbols.WHITESPACE_CHARS  = Flang.Util.Set{" ", "\t", Symbols.NEWLINE}

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

function Symbols.isKeyword(e)
  return Flang.Util.contains(Symbols.KEYWORDS, e)
end

function Symbols.isOneCharacterSymbol(e)
  return Flang.Util.contains(Symbols.ONE_CHARACTER_SYMBOLS, e)
end

function Symbols.isTwoCharacterSymbol(e)
  return Flang.Util.contains(Symbols.TWO_CHARACTER_SYMBOLS, e)
end

function Symbols.isWhitespace(e)
  return Flang.Util.contains(Symbols.WHITESPACE_CHARS, e)
end

function Symbols.isIdentifierStartChar(e)
  return Flang.Util.contains(Symbols.IDENTIFIER_STARTCHARS, e)
end

function Symbols.isIdentifierChar(e)
  return Flang.Util.contains(Symbols.IDENTIFIER_CHARS, e)
end

function Symbols.isNumberStartChar(e)
  return Flang.Util.contains(Symbols.NUMBER_STARTCHARS, e)
end

function Symbols.isNumberChar(e)
  return Flang.Util.contains(Symbols.NUMBER_CHARS, e)
end

function Symbols.isStringStartChar(e)
  return Flang.Util.contains(Symbols.STRING_STARTCHARS, e)
end
