if not Flang then Flang = {} end
Symbols = {}
Flang.Symbols = Symbols
Symbols.__index = Symbols

-- turn the Table of {element, ...} into a table of {element = true, ...}
-- will be queried later
function Symbols:Set(table)
  local s = {}
  for _,v in pairs(table) do s[v] = true end
  return s
end

-- Returns true if element in set, nil otherwise
function Symbols:contains(set, element)
  return set[element]
end

function Symbols:isKeyword(e)
  return Symbols:contains(Symbols.KEYWORDS, e)
end

function Symbols:isOneCharacterSymbol(e)
  return Symbols:contains(Symbols.ONE_CHARACTER_SYMBOLS, e)
end

function Symbols:isTwoCharacterSymbol(e)
  return Symbols:contains(Symbols.TWO_CHARACTER_SYMBOLS, e)
end

Symbols.KEYWORDS = Symbols:Set{
  "if",
  -- "then",
  "else",
  -- "elif",
  -- "endif",
  "while",
  "for",
  -- "loop",
  -- "endloop",
  "print",
  "return",
  "exit"
}

Symbols.ONE_CHARACTER_SYMBOLS = Symbols:Set{
  "=",
  "(", ")",
  "{", "}",
  "<", ">",
  "/", "*", "+", "-",
  "!", "&",
  ".",
  ";"
}

Symbols.TWO_CHARACTER_SYMBOLS = Symbols:Set{
  "==",
  "<=",
  ">=",
  -- "<>",
  "!=",
  -- "++",
  -- "**",
  -- "--",
  -- "+=",
  -- "-=",
  "||"
}

-- IDENTIFIER_STARTCHARS = string.letters
-- IDENTIFIER_CHARS      = string.letters + string.digits + "_"
--
-- NUMBER_STARTCHARS     = string.digits
-- NUMBER_CHARS          = string.digits + "."

IDENTIFIER_STARTCHARS = Symbols:Set{"a", "b", "c", "d", "e", "f", "g", "h",
  "i", "j", "k", "l", "m", "n", "o", "p",
  "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
}
IDENTIFIER_CHARS    = Symbols:Set{"a", "b", "c", "d", "e", "f", "g", "h",
  "i", "j", "k", "l", "m", "n", "o", "p",
  "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

  "_"
}

NUMBER_STARTCHARS     = Symbols:Set{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
NUMBER_CHARS          = Symbols:Set{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."}

STRING_STARTCHARS = Symbols:Set{"'", '"'}
WHITESPACE_CHARS  = Symbols:Set{" ", "\t", "\n"}

-----------------------------------------------------------------------
-- TokenTypes for things other than symbols and keywords
-----------------------------------------------------------------------
STRING             = "String"
IDENTIFIER         = "Identifier"
NUMBER             = "Number"
WHITESPACE         = "Whitespace"
COMMENT            = "Comment"
EOF                = "Eof"

-- a = "*"
-- print(Symbols:contains(Symbols.KEYWORDS, a))
-- print(Symbols:contains(Symbols.ONE_CHARACTER_SYMBOLS, a))
-- print(Symbols:contains(Symbols.TWO_CHARACTER_SYMBOLS, a))
--
-- a = "!="
-- print(Symbols:isKeyword(a))
-- print(Symbols:isOneCharacterSymbol(a))
-- print(Symbols:isTwoCharacterSymbol(a))
