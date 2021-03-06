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
localRequire("scope")
localRequire("interpreter")

-- Create the lua function (mods) namespace
if not Flang.LuaFunction then Flang.LuaFunction = {} end

-- Start loading lua functions
localRequire("lua_functions/core")
localRequire("lua_functions/table")
localRequire("lua_functions/string")
