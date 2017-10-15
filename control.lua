require("controller.FlangChip")
GlobalData = require("controller.GlobalData")

local PLAYER_ID_TO_ENTITY_MAPPING = {}
local CHIP_TABLE = {}

function get_player_last_chip_entity(player_id)
  -- create the table if needed
  if PLAYER_ID_TO_ENTITY_MAPPING["player_last_chip_entity_mapping"] then
    local entity = PLAYER_ID_TO_ENTITY_MAPPING["player_last_chip_entity_mapping"][player_id]
    if entity and entity.valid then
      return entity
    else
      -- get rid of this hot entity
      PLAYER_ID_TO_ENTITY_MAPPING["player_last_chip_entity_mapping"][player_id] = nil
      return nil
    end
  else
    return nil
  end
end

function set_player_last_chip_entity(player_id, entity)
  if not PLAYER_ID_TO_ENTITY_MAPPING["player_last_chip_entity_mapping"] then
    PLAYER_ID_TO_ENTITY_MAPPING["player_last_chip_entity_mapping"] = {}
  end

  PLAYER_ID_TO_ENTITY_MAPPING["player_last_chip_entity_mapping"][player_id] = entity
end

--[[
  The source is the preloaded source from storage
]]
function create_editor_window(player, source)
  -- Get rid of any window that's already present
  if player.gui.left.flang_parent_window_flow then player.gui.left.flang_parent_window_flow.destroy() end

  -- create the parent window for the whole thing
  local flang_parent_window_flow = player.gui.left.flang_parent_window_flow
  if not flang_parent_window_flow then
    -- create the parent flow
    flang_parent_window_flow = player.gui.left.add{type = "flow", name = "flang_parent_window_flow", direction = "vertical"}
  end

  -- create the menu
  menu_flow = flang_parent_window_flow.add{type = "flow", name = "flang_menu_flow", direction = "horizontal"}
  -- inside the menu we add the buttons and stuff
  button_style = "slot_button_style"
  close_button = menu_flow.add{type = "sprite-button", name = "flang_menu_close_button",
      sprite = "close",
      style=button_style}
  play_button = menu_flow.add{type = "sprite-button", name = "flang_menu_play_button",
      sprite = "play",
      style=button_style}
  stop_button = menu_flow.add{type = "sprite-button", name = "flang_menu_stop_button",
      sprite = "stop",
      style=button_style}

  -- create the editor
  editor_window = flang_parent_window_flow.add{type="text-box", name="flang_editor_window",
    style="flang_editor_window_style", text=source}

  -- create the info window
  info_window = flang_parent_window_flow.add{
    type="text-box", name="flang_info_window",
    style="flang_info_window_style"
  }
end

function close_editor_window(player, flangchip_entity)
  if player.gui.left.flang_parent_window_flow then
    player.gui.left.flang_parent_window_flow.destroy()
  end
end

--[[
  Called when the chip dies or is mined.
]]
function delete_chip_controller(entity)
  if is_entity_flang_chip(entity) then
    id = entity.unit_number

    -- delete from global storage
    GlobalData.delete_entity_data(id)

    -- delete from local storage
    CHIP_TABLE[id] = nil
  end
end

function create_chip_controller(entity)
  if is_entity_flang_chip(entity) then
    id = entity.unit_number

    -- create the first record of the entity
    object_data = GlobalData.new_data_object()
    object_data.entity = entity
    GlobalData.write_entity_data(id, object_data)

    -- create the local chip
    printer_function = function(msg) player_log_print(msg) end
    chip = FlangChip:new({entity = entity, printer = printer_function})
    CHIP_TABLE[id] = chip
  end
end

-------------------------- Chip Handling ---------------------

--------------------------------------------------------------

script.on_event(defines.events.on_tick, function(event)
  if (event.tick % (60*5) == 0) then
    -- for entity_id, chip in pairs(CHIP_TABLE) do
    --   player_log_print(chip.source)
    --   chip:start_execution()
    --   result = chip:execute()
    --
    --   print_pairs(result)
    -- end
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  create_chip_controller(event.created_entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  create_chip_controller(event.created_entity)
end)

-------------------------- GUI -------------------------------

--------------------------------------------------------------

script.on_event("flang-open-editor", function(event)
  player = game.players[event.player_index]

  -- Make sure the entity is a flang chip
  if player.selected and is_entity_flang_chip(player.selected) then
    entity = player.selected

    source = GlobalData.get_entity_data(entity.unit_number)["source"]
    set_player_last_chip_entity(event.player_index, entity)
    create_editor_window(player, source)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]

  -- if the close button was clicked, close the parent window
	if event.element.name == "flang_menu_close_button" then
    close_editor_window(player)
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  local player = game.players[event.player_index]

	if event.element.name == "flang_editor_window" then
    local text = event.element.text

    local entity = get_player_last_chip_entity(event.player_index)
    if entity then
      local id = entity.unit_number

      -- Globals
      GlobalData.write_entity_source(id, text)

      -- Local setting
      -- The chip should exist already
      local chip = CHIP_TABLE[id]
      chip:update_source(text)
    end
  end
end)

-------------------------- Deletion --------------------------

--------------------------------------------------------------

script.on_event(defines.events.on_entity_died, function(event)
  delete_chip_controller(event.entity)
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
  delete_chip_controller(event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
  delete_chip_controller(event.entity)
end)

-------------------------- Initialization --------------------

--------------------------------------------------------------

script.on_init(function()
  -- recreate the controller table from the global table
  player_log_print("on init")
end)

script.on_configuration_changed(function()
  -- recreate the controller table from the global table
  player_log_print("on config changed")
end)

script.on_load(function()
  printer_function = function(msg) player_log_print(msg) end

  -- recreate the controller table from the global table
  for entity_id, chip_data in pairs(GlobalData.get_all_entities()) do
    chip = FlangChip:new({
      entity = chip_data["entity"],
      source = chip_data["source"],
      is_running = chip_data["is_running"],
      printer = printer_function
    })
    CHIP_TABLE[entity_id] = chip
  end
end)

-------------------------- Misc ------------------------------

--------------------------------------------------------------

function is_entity_flang_chip(entity)
  return entity.name == "flang-chip" and entity.valid
end

function player_log_print(msg)
  if game == nil then
    return
  end

  for index,player in pairs(game.connected_players) do
    player.print(msg)
  end
end

function print_pairs(table)
  for k,v in pairs(table) do
    player_log_print("key " .. k)
    player_log_print("val " .. v)
  end
end
