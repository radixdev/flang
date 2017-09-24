GlobalData = require("controller.GlobalData")

function get_player_last_chip_entity(player_id)
  -- create the table if needed
  if global["player_last_chip_entity_mapping"] then
    return global["player_last_chip_entity_mapping"][player_id]
  else
    return nil
  end
end

function set_player_last_chip_entity(player_id, entity)
  if not global["player_last_chip_entity_mapping"] then
    player.print("creating table")
    global["player_last_chip_entity_mapping"] = {}
  end

  global["player_last_chip_entity_mapping"][player_id] = entity
end

function create_editor_window(player, entity)
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
  close_button = menu_flow.add{type = "sprite-button", name = "flang_menu_close_button",
      sprite = "close",
      style="slot_button_style"}

  -- create the editor
  source = GlobalData.get_entity_data(entity.unit_number)["source"]
  editor_window = flang_parent_window_flow.add{type="text-box", name="flang_editor_window",
    style="flang_editor_window_style", text=source}

  -- create the info window
  info_window = flang_parent_window_flow.add{
    type="text-box", name="flang_info_window",
    style="flang_info_window_style",
    text = "ayyyy\nlmao"
  }
end

function close_editor_window(player, flangchip_entity)
  if player.gui.left.flang_parent_window_flow then
    player.gui.left.flang_parent_window_flow.destroy()
  end
end

function is_entity_flang_chip(entity)
  return entity.name == "flang-chip"
end

--[[
  Called when the chip dies or is mined.
]]
function delete_chip_controller(entity)
  if is_entity_flang_chip(entity) then
    -- delete from the tables
    GlobalData.delete_entity_data(entity.unit_number)
  end
end

script.on_event(defines.events.on_tick, function(event)
  -- if (event.tick % 60 == 0) then
  --   for index,player in pairs(game.connected_players) do  --loop through all online players on the server
  --     player.print("tick " .. event.tick)
  --   end
  -- end
end)

script.on_event("flang-open-editor", function(event)
  player = game.players[event.player_index]

  -- Make sure the entity is a flang chip
  if player.selected and is_entity_flang_chip(player.selected) then
    entity = player.selected
    create_editor_window(player, entity)
    set_player_last_chip_entity(event.player_index, entity)
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
    -- update the relevant controller
    text = event.element.text

    -- need the entity!!!
    entity = get_player_last_chip_entity(event.player_index)
    if entity then
      GlobalData.write_entity_source(entity.unit_number, text)
    end
  end
end)

script.on_event(defines.events.on_entity_died, function(event)
  delete_chip_controller(event.entity)
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
  delete_chip_controller(event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
  delete_chip_controller(event.entity)
end)

script.on_init(function()
  -- recreate the controller table from the global table
end)

script.on_configuration_changed(function()
  -- recreate the controller table from the global table
end)
