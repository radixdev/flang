--[[
  A whole bunch of shit to save in the global table across saves.

  Note that while values can be Factorio objects, KEYS must be primitives

  see http://lua-api.factorio.com/latest/Global.html
]]

local GlobalData = {}

local GLOBAL_TABLE_NAME = "chip_data"

--[[
  An empty data object for marshalling
]]
function GlobalData.new_data_object()
  return {
    -- The code in the editor
    source = "",
    -- is the code running or nah?
    is_running = false,
    -- the entity referenced by the id
    entity = nil
  }
end

function create_global_table()
  if not global[GLOBAL_TABLE_NAME] then
    -- create the table
    global[GLOBAL_TABLE_NAME] = {}
  end
end

function GlobalData.write_entity_data(entity_id, data_object)
  create_global_table()
  global[GLOBAL_TABLE_NAME][entity_id] = data_object
end

function GlobalData.write_entity_source(entity_id, source)
  local data = GlobalData.get_entity_data(entity_id)
  data["source"] = source
  GlobalData.write_entity_data(entity_id, data)
end

function GlobalData.write_entity_is_running(entity_id, is_running)
  local data = GlobalData.get_entity_data(entity_id)
  data["is_running"] = is_running
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
  create_global_table()

  if not global[GLOBAL_TABLE_NAME][entity_id] then
    global[GLOBAL_TABLE_NAME][entity_id] = GlobalData.new_data_object()
  end

  -- get the table
  return global[GLOBAL_TABLE_NAME][entity_id]
end

--[[
  Reads whatever the fuck is present in the global table at the time of reading.
  Does not modify the global table in any way!
]]
function GlobalData.get_all_entities()
  return global[GLOBAL_TABLE_NAME] or {}
end

return GlobalData
