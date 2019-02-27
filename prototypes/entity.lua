-- see \Factorio\data\base\prototypes\entity\entities.lua line 10459
local flangChipEntity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
flangChipEntity.name = "flang-chip"
flangChipEntity.minable = {hardness = 0.2, mining_time = 0.5, result = "flang-chip"}
flangChipEntity.max_health = 271
flangChipEntity.icon = "__Flang__/graphics/flangchip.png"
flangChipEntity.item_slot_count = 100

local invisChipEntity = table.deepcopy(data.raw["programmable-speaker"]["programmable-speaker"])
invisChipEntity.name = "invis-flang-chip"
invisChipEntity.minable = {hardness = 0, mining_time = 0, result = "invis-flang-chip"}
invisChipEntity.max_health = 1
invisChipEntity.icon = "__Flang__/graphics/flangchip.png"
invisChipEntity.item_slot_count = 100
invisChipEntity.selectable_in_game = false
invisChipEntity.collision_mask = {"not-colliding-with-itself"}
invisChipEntity.flags = {"player-creation", "not-repairable"}
invisChipEntity.sprite =
{
  layers =
  {
    {
      filename = "__Flang__/graphics/empty.png",
      priority = "extra-high",
      width = 30,
      height = 89,
      shift = util.by_pixel(-2, -39.5),
      hr_version =
      {
        filename = "__Flang__/graphics/empty.png",
        priority = "extra-high",
        width = 59,
        height = 178,
        shift = util.by_pixel(-2.25, -39.5),
        scale = 0.5
      }
    },
    {
      filename = "__Flang__/graphics/empty.png",
      priority = "extra-high",
      width = 119,
      height = 25,
      shift = util.by_pixel(52.5, -2.5),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__Flang__/graphics/empty.png",
        priority = "extra-high",
        width = 237,
        height = 50,
        shift = util.by_pixel(52.75, -3),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
  }
}
-- https://wiki.factorio.com/Types/Energy
invisChipEntity.energy_usage = "150kW"
-- https://wiki.factorio.com/Types/ElectricUsagePriority
invisChipEntity.energy_source = {
      type = "electric",
      usage_priority = "terciary",
      emissions = 0
    }

data:extend({flangChipEntity, invisChipEntity})
