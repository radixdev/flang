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
