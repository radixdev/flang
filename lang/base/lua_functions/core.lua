-- who: `core.lua`
-- what: Standard library for the Flang language

-- Add our class to the global namespace for lua functions
-- The module name should be capitalized. It also should be
-- unique, otherwise module overwriting will occur.
local Core = {}
Core.__index = Core
Flang.LuaFunction.Core = Core
-- Now start adding your functions below

--[[
  * "wrapper" is the flang runner (Factorio) state information for
    the chip itself. This argument is passed into every function call.
    See `FlangChip.lua` for the contents. You can expect the chip entity
    for example.
  * "flangArguments" is an array of arguments from the Flang code itself. It is 1 indexed.
]]
function Core:helloWorld(wrapper, flangArguments)
  -- Your function can return values back to the code in a table
  return {
    -- This key is actually returned to the code
    result = flangArguments[1] + 1
  }
end

function Core:luaPrint(wrapper, flangArguments)
  print(flangArguments[1])
  return nil
end

function Core:writeVirtualSignal(wrapper, flangArguments)
  local virtualSignalIndex = flangArguments[1]
  if (virtualSignalIndex < 0 or virtualSignalIndex > 100) then
    -- This is a game ending exception...
    -- Let's just soft crash!
    return {
      hasError = true,
      errorMessage = "Core:writeVirtualSignal cannot accept a signal index outside the bounds [0..100]"
    }
  end

  local virtualSignalName = flangArguments[2]

  local entity = wrapper.entity
  local combinatorBehavior = entity.get_control_behavior()
  combinatorBehavior.set_signal(virtualSignalIndex, {
    signal = {
      type = "virtual",
      name = "signal-" .. virtualSignalName
    }
  })
end
