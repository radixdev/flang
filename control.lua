--[[
  defines.events.on_selected_entity_changed is called -> player clicked on chip
    display a gui
  defines.events.on_gui_text_changed for when the text is changed
    update the saved text for the chip
  defines.events.on_gui_click -> some control button (start/stop) was pressed

]]

--[[
  Gets a chip object from its game entity

  chip object: {
    body - Text body of the editor
  }
]]
function get_chip_object(chip_entity)

end

function create_editor_window(player, chip_entity)
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
  editor_window = flang_parent_window_flow.add{type="text-box", name="flang_editor_window", style="flang_editor_window_style"}

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
  if player.selected and player.selected.name == "flang-chip" then
    flangchip_entity = player.selected
    create_editor_window(player, flangchip_entity)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]

  -- if the close button was clicked, close the parent window
	if event.element.name == "flang_menu_close_button" then
    close_editor_window(player)
  end
end)
