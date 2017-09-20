--[[
  defines.events.on_selected_entity_changed is called -> player clicked on chip
    display a gui
  defines.events.on_gui_text_changed for when the text is changed
    update the saved text for the chip
  defines.events.on_gui_click -> some control button (start/stop) was pressed

]]

function create_editor_window(player)
  -- create the parent window for the whole thing
  local parent_window_flow = player.gui.center.parent_window_flow
  if not parent_window_flow then
    -- create the parent flow
    parent_window_flow = player.gui.center.add{type = "flow", name = "parent_window_flow", direction = "vertical"}
  end

  -- create the editor
  editor_window = parent_window_flow.add{type="text-box", name="flang_editor_window",
        caption="Hi", style="flang_editor_window_style"}
  info_window = parent_window_flow.add{
    type="text-box", name="flang_info_window",
    style="flang_info_window_style",
    text = "ayyyy\nlmao"
  }
end


script.on_event({defines.events.on_tick},
   function (e)
      -- if e.tick % 60 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just 1/second
      --    for index,player in pairs(game.connected_players) do  --loop through all online players on the server
      --       --if they're wearing our armor
      --       if player.character and player.get_inventory(defines.inventory.player_armor).get_item_count("fire-armor") >= 1 then
      --          --create the fire where they're standing
      --          player.surface.create_entity{name="fire-flame", position=player.position, force="neutral"}
      --       end
      --    end
      -- end
   end
)

script.on_init(function()
	for _, player in pairs(game.players) do
    -- add_top_button(player)
    player.print("on init")
  end
end)

script.on_configuration_changed(function()
	for _, player in pairs(game.players) do
    -- add_top_button(player)
    player.print("on config changeddd")
    create_editor_window(player)

    -- player.gui.center.add{type="text-box", name="text-here",
    --   caption="Hi", style="big_box_style"}
  end
end)

script.on_event(defines.events.on_player_created, function(event)
	-- add_top_button(game.players[event.player_index])
  player.print("player created "..event.player_index)
end)
