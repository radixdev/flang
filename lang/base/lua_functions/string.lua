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

-- Return an array of each character in the string
function String:getChars(wrapper, flangArguments)
  local chars = {}
  local str = flangArguments[1]
  for i in str:gmatch('.') do
    table.insert(chars, i)
  end

  return {
    result = chars
  }
end

function String:upper(wrapper, flangArguments)
  return {
    result = flangArguments[1]:upper()
  }
end

function String:lower(wrapper, flangArguments)
  return {
    result = flangArguments[1]:lower()
  }
end

function String:sub(wrapper, flangArguments)
  local str = flangArguments[1]
  local startIndex = flangArguments[2]
  local endIndex = flangArguments[3]

  local result
  if (endIndex) then
    result = str:sub(startIndex, endIndex)
  else
    result = str:sub(startIndex)
  end
  
  return {
    result = result
  }
end
