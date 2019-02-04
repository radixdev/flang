-- imports all of the necessary FLANG classes in the base folder
local folderOfThisFile = (...):match("(.-)[^%.]+$")

function localRequire(module)
  require(folderOfThisFile..module)
end

-- Create our namespace
if not Flang then Flang = {} end

-- These imports MUST be in the proper dependency order or the loading will fail
localRequire("util")

localRequire("character")
localRequire("symbols")
localRequire("token")
localRequire("scanner")
localRequire("lexer")

localRequire("node")
localRequire("parser")
localRequire("interpreter")

-- Start loading lua functions
if not Flang.LuaFunction then Flang.LuaFunction = {} end
localRequire("lua_functions/core")
