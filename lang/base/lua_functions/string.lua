-- who: `string.lua`
-- what: String functions library

-- Add our class to the global namespace for lua functions.
-- Since this is a primitive, we leave it lowercase in the LuaFunction table
local String = {}
String.__index = String
-- Adding both cases for ease
Flang.LuaFunction.String = String
Flang.LuaFunction.string = String

function String:length(wrapper, flangArguments)
  return {
    result = flangArguments[1]:len()
  }
end
