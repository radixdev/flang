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

function Core:tick(wrapper, flangArguments)
  return {
    result = Flang.tick
  }
end

function Core:luaPrint(wrapper, flangArguments)
  local msg = flangArguments[1]
  if (Util.isTable(msg)) then
    print(Util.set_to_string_nested_nodes(msg))
  else
    print(msg)
  end
  return nil
end

-- args = (index, signal name, signal count)
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
  local virtualSignalCount = flangArguments[3]

  local entity = wrapper.entity
  local combinatorBehavior = entity.get_control_behavior()
  combinatorBehavior.set_signal(virtualSignalIndex, {
    signal = {
      type = "virtual",
      name = "signal-" .. virtualSignalName
    },
    count = virtualSignalCount
  })
end

-- args = (virtual signal name, network color)
function Core:readVirtualSignal(wrapper, flangArguments)
  local virtualSignalName = flangArguments[1]
  local entity = wrapper.entity
  if (entity == nil) then
    return {
      hasError = true,
      errorMessage = "Entity is nil"
    }
  end

  if (virtualSignalName == "10") then
    return {
      hasError = true,
      errorMessage = "bad virt name" .. virtualSignalName
    }
  end
  local combinatorBehavior = entity.get_control_behavior()

  -- Check the network type
  local circuitNetworkName = flangArguments[2]
  local circuitNetworkColor

  if (circuitNetworkName == "red") then
    circuitNetworkColor = defines.wire_type.red
  elseif (circuitNetworkName == "green") then
    circuitNetworkColor = defines.wire_type.green
  elseif (circuitNetworkName == "copper") then
    circuitNetworkColor = defines.wire_type.copper
  else
    return {
      hasError = true,
      errorMessage = "Circuit network with name " .. circuitNetworkName .. " is invalid. Try ['red', 'green', 'copper']"
    }
  end

  local circuitNetwork = combinatorBehavior.get_circuit_network(circuitNetworkColor)
  if (circuitNetwork == nil) then
    return {
      hasError = true,
      errorMessage = "Core:writeVirtualSignal has no network attached on type: " .. circuitNetworkName
    }
  end

  local signal = {
      type = "virtual",
      name = "signal-" .. virtualSignalName
  }
  return {
    result = circuitNetwork.get_signal(signal)
  }
end
