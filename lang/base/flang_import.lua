-- imports all of the necessary FLANG classes in the base folder
local folderOfThisFile = (...):match("(.-)[^%.]+$")

function localRequire(module)
  require(folderOfThisFile..module)
end

localRequire("symbols")
localRequire("character")
localRequire("lexer")
localRequire("token")
localRequire("scanner")

localRequire("node")
localRequire("parser")
localRequire("interpreter")

localRequire("util")
