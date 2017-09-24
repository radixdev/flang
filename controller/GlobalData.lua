--[[
  A whole bunch of shit to save in the global table across saves

  see http://lua-api.factorio.com/latest/Global.html
]]

local GlobalData = {}

local GLOBAL_TABLE_NAME = "chip_data"

--[[
  An empty data object for marshalling
]]
function GlobalData.new_data_object()
  return {
    source = ""
  }
end

function GlobalData.write_entity_data(entity_id, data_object)
  if global[GLOBAL_TABLE_NAME] and global[GLOBAL_TABLE_NAME][entity_id] then
    global[GLOBAL_TABLE_NAME][entity_id] = data_object
  end
end

function GlobalData.write_entity_source(entity_id, source)
  local data = GlobalData.get_entity_data(entity_id)
  data["source"] = source
  GlobalData.write_entity_data(entity_id, data)
end

function GlobalData.delete_entity_data(entity_id)
  GlobalData.write_entity_data(entity_id, nil)
end

--[[
  Returns a data object for the saved entity in global state.

  If the entity hasn't been saved, then the data object will be empty
]]
function GlobalData.get_entity_data(entity_id)
  if not global[GLOBAL_TABLE_NAME] then
    -- create the table
    global[GLOBAL_TABLE_NAME] = {}

    global[GLOBAL_TABLE_NAME][entity_id] = GlobalData.new_data_object()
  end

  -- get the table
  return global[GLOBAL_TABLE_NAME][entity_id]
end

return GlobalData
