-- who: `core.lua`
-- what: Standard library for the Flang language

-- Add our class to the global namespace for lua functions
local Core = {}
Core.__index = Core
Flang.LuaFunction.Core = Core

-- Now start adding your functions below
function Core:helloWorld(entity, flangArguments)

end
