-- who: `core.lua`
-- what: Standard library for the Flang language

-- Add our class to the global namespace for lua functions
-- The module name should be capitalized. It also should be
-- unique, otherwise module overwriting will occur.
local Core = {}
Core.__index = Core
Flang.LuaFunction.Core = Core

print("core lib added")

-- Now start adding your functions below
function Core:helloWorld(entity, flangArguments)
  print("hello world!")
end
