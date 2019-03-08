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
  print(Util.concat_table_to_string(flangArguments))
  return nil
end

function Core:print(wrapper, flangArguments)
  local msg = Util.concat_table_to_string(flangArguments)
  wrapper.printer(wrapper.entity, msg, false)
  return nil
end

-- args = (index, virtual signal name suffix, signal count)
function Core:writeVirtualSignal(wrapper, flangArguments)
  local signalType = "virtual"
  local entity = wrapper.entity
  local signalIndex = flangArguments[1]
  local signalName = "signal-" .. flangArguments[2]
  local signalCount = flangArguments[3]

  return writeSignal(entity, signalIndex, signalType, signalName, signalCount)
end

-- args = (index, signal name, signal count)
function Core:writeItemSignal(wrapper, flangArguments)
  local signalType = "item"
  local entity = wrapper.entity
  local signalIndex = flangArguments[1]
  local signalCount = flangArguments[3]
  local signalName = flangArguments[2]

  return writeSignal(entity, signalIndex, signalType, signalName, signalCount)
end

-- args = (virtual signal name, network color)
function Core:readVirtualSignal(wrapper, flangArguments)
  local signalType = "virtual"
  local entity = wrapper.entity
  local signalName = "signal-" .. flangArguments[1]
  local circuitNetworkName = flangArguments[2]

  return readSignal(entity, circuitNetworkName, signalType, signalName)
end

function Core:readItemSignal(wrapper, flangArguments)
  local signalType = "item"
  local entity = wrapper.entity
  local signalName = flangArguments[1]
  local circuitNetworkName = flangArguments[2]

  return readSignal(entity, circuitNetworkName, signalType, signalName)
end

-----------------------------------------------------------------------

-- Private functions

-----------------------------------------------------------------------

-- signalType -> "item" or "virtual"
function writeSignal(entity, signalIndex, signalType, signalName, signalCount)
  if (signalIndex < 0 or signalIndex > 100) then
    -- This is a game ending exception...
    -- Let's just soft crash!
    return {
      hasError = true,
      errorMessage = "Core:Write Signal cannot accept a signal index outside the bounds [0..100]"
    }
  end

  local combinatorBehavior = entity.get_control_behavior()
  combinatorBehavior.set_signal(signalIndex, {
    signal = {
      type = signalType,
      name = signalName
    },
    count = signalCount
  })
end

function readSignal(entity, circuitNetworkName, signalType, signalName)
  if (entity == nil) then
    return {
      hasError = true,
      errorMessage = "Entity is nil"
    }
  end

  local combinatorBehavior = entity.get_control_behavior()

  -- Check the network type
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
      errorMessage = "Core:Read Signal has no network attached on type: " .. circuitNetworkName
    }
  end

  local signal = {
      type = signalType,
      name = signalName
  }
  return {
    result = circuitNetwork.get_signal(signal)
  }
end
