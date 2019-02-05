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
-- "entity" is the flang chip entity. This argument is passed into every function call
-- "flangArguments" is an array of arguments from the Flang code itself. It is 1 indexed.
function Core:helloWorld(entity, flangArguments)
  print("hello world!")
end
