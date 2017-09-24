--[[
  defines.events.on_selected_entity_changed is called -> player clicked on chip
    display a gui
  defines.events.on_gui_text_changed for when the text is changed
    update the saved text for the chip
  defines.events.on_gui_click -> some control button (start/stop) was pressed

]]

function create_editor_window(player)
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

function close_editor_window(player)
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

-- script.on_init(function()
-- 	for _, player in pairs(game.players) do
--     -- create_editor_window(player)
--   end
-- end)
--
-- script.on_configuration_changed(function()
-- 	for _, player in pairs(game.players) do
--     player.print("on config changed")
--     -- create_editor_window(player)
--   end
-- end)
--
-- script.on_event(defines.events.on_player_created, function(event)
--   player = game.players[event.player_index]
--   -- create_editor_window(player)
-- end)

-- script.on_event(defines.events.on_selected_entity_changed, function(event)
--   player = game.players[event.player_index]
--   if (player.selected ~= nil) then
--     player.print("last selected entity " .. player.selected.unit_number)
--   else
--     player.print("nil selected entity ")
--   end
--
--   if (player.opened) then
--     -- player.print("player opened " .. tostring(player.opened))
--     create_editor_window(player)
--   end
-- end)

script.on_event("flang-open-editor", function(event)
  player = game.players[event.player_index]

  -- Make sure the entity is a flang chip
  if player.selected and player.selected.name == "flang-chip" then
    flangchip_entity = player.selected
    create_editor_window(player)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]

  -- if the close button was clicked, close the parent window
	if event.element.name == "flang_menu_close_button" then
    close_editor_window(player)
  end
end)























-- script.on_event({defines.events.on_tick},
--    function (e)
--       -- if e.tick % 60 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just 1/second
--       --    for index,player in pairs(game.connected_players) do  --loop through all online players on the server
--       --       --if they're wearing our armor
--       --       if player.character and player.get_inventory(defines.inventory.player_armor).get_item_count("fire-armor") >= 1 then
--       --          --create the fire where they're standing
--       --          player.surface.create_entity{name="fire-flame", position=player.position, force="neutral"}
--       --       end
--       --    end
--       -- end
--    end
-- )
