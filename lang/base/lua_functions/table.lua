-- who: `table.lua`
-- what: Table functions library

-- Add our class to the global namespace for lua functions.
-- Since this is a primitive, we leave it lowercase in the LuaFunction table
local Table = {}
Table.__index = Table
-- Adding both cases for ease
Flang.LuaFunction.Table = Table
Flang.LuaFunction.table = Table

function Table:length(wrapper, flangArguments)
  return {
    result = #flangArguments[1]
  }
end

function Table:append(wrapper, flangArguments)
  local varTable = flangArguments[1]
  local appendValue = flangArguments[2]
  table.insert(varTable, appendValue)

  return nil
end
