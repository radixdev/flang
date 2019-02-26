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
invisChipEntity.flags = {"player-creation", "not-repairable"},

data:extend({flangChipEntity, invisChipEntity})
